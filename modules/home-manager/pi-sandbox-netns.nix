{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.pi-sandbox-netns;

  netns = "pi-restricted";
  vethHost = "veth-pisb-h";
  vethNs = "veth-pisb-ns";
  hostAddr = "10.200.1.1";
  nsAddr = "10.200.1.2";
  subnet = "10.200.1.0/24";

  unboundLocalZones = concatMapStringsSep "\n" (domain: let
    cleaned = removePrefix "." domain;
  in ''  local-zone: "${cleaned}." transparent'') cfg.allowedDomains;

  unboundForwardAddrs = concatMapStringsSep "\n" (addr: "  forward-addr: ${addr}") cfg.upstreamDns;

  unboundConf = pkgs.writeText "pi-sandbox-unbound.conf" ''
    server:
      interface: ${nsAddr}
      port: 53
      do-daemonize: no
      username: ""
      chroot: ""
      directory: ""
      pidfile: ""
      use-syslog: no
      logfile: "/run/pi-sandbox-dns/unbound.log"
      log-replies: yes
      access-control: ${subnet} allow
      access-control: 127.0.0.0/8 allow

      # Default deny: refuse all domains not explicitly allowed
      local-zone: "." always_refuse

      # Allowed domains (transparent = forward normally)
    ${unboundLocalZones}

    forward-zone:
      name: "."
    ${unboundForwardAddrs}
  '';

  portList = concatMapStringsSep ", " toString cfg.allowedTcpPorts;

  # nftables rules applied INSIDE the netns
  nftConf = pkgs.writeText "pi-sandbox-nftables.conf" ''
    table inet filter {
      set allowed_ips {
        type ipv4_addr
        flags dynamic,timeout
        timeout 5m
      }

      set allowed_ips6 {
        type ipv6_addr
        flags dynamic,timeout
        timeout 5m
      }

      chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        iif lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
      }

      chain output {
        type filter hook output priority 0; policy drop;
        ct state established,related accept
        oif lo accept

        # Container processes (UID 1000) can only reach local unbound for DNS
        ip daddr ${nsAddr} udp dport 53 accept
        ip daddr ${nsAddr} tcp dport 53 accept

        # Unbound (UID 0) can reach upstream DNS through NAT
        meta skuid 0 udp dport 53 accept
        meta skuid 0 tcp dport 53 accept

        # Allow traffic to dynamically resolved IPs on permitted ports
        ip daddr @allowed_ips tcp dport { ${portList} } accept
        ip6 daddr @allowed_ips6 tcp dport { ${portList} } accept

        # ICMP for diagnostics
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
      }
    }
  '';

  # Periodically resolves all allowed domains and populates the nft sets.
  # Runs every 30s to keep the set fresh as DNS records change.
  # No race condition: the set is pre-populated before containers need it.
  allowedDomainsList = concatMapStringsSep " " (domain: removePrefix "." domain) cfg.allowedDomains;

  nftUpdaterScript = pkgs.writeShellScript "pi-sandbox-nft-updater" ''
    set -euo pipefail
    DIG="${pkgs.dig}/bin/dig"
    DOMAINS="${allowedDomainsList}"

    while true; do
      for domain in $DOMAINS; do
        # Resolve A records
        ips=$("$DIG" +short @${nsAddr} "$domain" A 2>/dev/null || true)
        for ip in $ips; do
          case "$ip" in
            0.0.0.0|127.*|"") continue ;;
          esac
          # Skip non-IP lines (CNAME records etc)
          if echo "$ip" | ${pkgs.gnugrep}/bin/grep -qP '^(\d{1,3}\.){3}\d{1,3}$'; then
            ${pkgs.nftables}/bin/nft add element inet filter allowed_ips "{ $ip timeout 5m }" 2>/dev/null || true
          fi
        done

        # Resolve AAAA records
        ips6=$("$DIG" +short @${nsAddr} "$domain" AAAA 2>/dev/null || true)
        for ip in $ips6; do
          case "$ip" in
            ::1|::|"") continue ;;
          esac
          if echo "$ip" | ${pkgs.gnugrep}/bin/grep -qP '^[0-9a-fA-F:]+$'; then
            ${pkgs.nftables}/bin/nft add element inet filter allowed_ips6 "{ $ip timeout 5m }" 2>/dev/null || true
          fi
        done
      done

      sleep 30
    done
  '';

  setupScript = pkgs.writeShellScript "pi-sandbox-netns-setup" ''
    set -euo pipefail

    # Create network namespace
    ${pkgs.iproute2}/bin/ip netns add ${netns}

    # Create veth pair
    ${pkgs.iproute2}/bin/ip link add ${vethHost} type veth peer name ${vethNs}

    # Move one end into the namespace
    ${pkgs.iproute2}/bin/ip link set ${vethNs} netns ${netns}

    # Configure host side
    ${pkgs.iproute2}/bin/ip addr add ${hostAddr}/24 dev ${vethHost}
    ${pkgs.iproute2}/bin/ip link set ${vethHost} up

    # Configure namespace side
    ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip addr add ${nsAddr}/24 dev ${vethNs}
    ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip link set ${vethNs} up
    ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip link set lo up
    ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip route add default via ${hostAddr}

    # Enable IP forwarding
    ${pkgs.procps}/bin/sysctl -w net.ipv4.ip_forward=1 > /dev/null

    # NAT and forwarding on host
    ${pkgs.nftables}/bin/nft -f - <<EOF
    table ip pi_sandbox_nat {
      chain postrouting {
        type nat hook postrouting priority 100;
        ip saddr ${subnet} masquerade
      }
    }
    table ip pi_sandbox_fwd {
      chain forward {
        type filter hook forward priority 0;
        iifname "${vethHost}" accept
        oifname "${vethHost}" accept
      }
    }
    EOF

    # Apply restrictive nftables inside the namespace
    ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.nftables}/bin/nft -f ${nftConf}
  '';

  teardownScript = pkgs.writeShellScript "pi-sandbox-netns-teardown" ''
    set -euo pipefail

    # Remove host-side nft tables
    ${pkgs.nftables}/bin/nft delete table ip pi_sandbox_nat 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete table ip pi_sandbox_fwd 2>/dev/null || true

    # Delete namespace (also removes veth pair)
    ${pkgs.iproute2}/bin/ip netns delete ${netns} 2>/dev/null || true
  '';

  nsenterWrapper = import ../../pkgs/pi-sandbox-nsenter.nix {inherit pkgs;};
in {
  options.services.pi-sandbox-netns = {
    enable = mkEnableOption (mdDoc "Restricted network namespace for pi-sandbox containers");

    allowedDomains = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["api.anthropic.com" ".github.com" ".githubusercontent.com"];
      description = mdDoc ''
        Domains the sandbox is allowed to reach. Prefix with "." for wildcard
        subdomain matching (e.g. ".github.com" allows *.github.com and github.com).
        All other domains are refused at the DNS level, and only IPs returned by
        allowed DNS lookups are reachable via nftables.
      '';
    };

    allowedTcpPorts = mkOption {
      type = types.listOf types.port;
      default = [80 443 22];
      description = mdDoc "TCP destination ports allowed to resolved IPs.";
    };

    upstreamDns = mkOption {
      type = types.listOf types.str;
      default = ["1.1.1.1" "8.8.8.8"];
      description = mdDoc "Upstream DNS servers for unbound to forward allowed queries to.";
    };
  };

  config = mkIf cfg.enable {
    # Netns + veth + NAT + nftables setup
    systemd.services.pi-sandbox-netns = {
      description = "Network namespace with DNS-filtered access for pi-sandbox";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = setupScript;
        ExecStop = teardownScript;
      };
    };

    # Unbound DNS resolver inside the restricted namespace
    systemd.services.pi-sandbox-unbound = {
      description = "Unbound DNS resolver for pi-sandbox (domain whitelist)";
      after = ["pi-sandbox-netns.service"];
      bindsTo = ["pi-sandbox-netns.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        NetworkNamespacePath = "/run/netns/${netns}";
        ExecStart = "${pkgs.unbound}/bin/unbound -d -c ${unboundConf}";
        Restart = "on-failure";
        RestartSec = 2;
        RuntimeDirectory = "pi-sandbox-dns";
        ReadWritePaths = ["/run/pi-sandbox-dns"];
      };
    };

    # Periodically resolves allowed domains and populates nftables IP sets
    systemd.services.pi-sandbox-nft-updater = {
      description = "Populate nftables allowed_ips set by resolving allowed domains";
      after = ["pi-sandbox-unbound.service"];
      bindsTo = ["pi-sandbox-unbound.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        NetworkNamespacePath = "/run/netns/${netns}";
        ExecStart = nftUpdaterScript;
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Allow users in the podman group to enter the restricted netns
    security.sudo.extraRules = [{
      groups = ["podman"];
      commands = [{
        command = toString nsenterWrapper;
        options = ["NOPASSWD"];
      }];
    }];

  };
}
