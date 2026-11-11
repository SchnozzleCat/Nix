# Fluxer chat (no nixpkgs package yet): the official docker compose bundle,
# vendored in ./fluxer (release 2026.1109.45135; to upgrade, replace
# docker-compose.yml + Caddyfile with the new bundle from
# https://docs.fluxer.com/compose/latest; docker-compose.proxy.yml is ours).
# Runs on rootful podman through its Docker-compatible API socket.
#
#   internet -> host Caddy (publicPort, TLS) -> 127.0.0.1:8080 (Fluxer edge)
#   calls    -> LiveKit directly on tcp/7881 + udp/7882 (published by podman)
#   fallback -> coturn on 3478, credentials from a shared secret. coturn
#               relays straight to the LiveKit container over the podman
#               bridge, no NAT hairpinning needed (see services.coturn).
#
# Everything lives on the RAID in ${stateDir}: the compose files, the
# secrets in .env (generated on first start) and all service data in data/.
# Back up the whole directory; the .env keys can't change afterwards.
{
  config,
  lib,
  pkgs,
  ...
}: let
  domain = "chat.schnozzlecat.xyz";
  # Public HTTPS port (TCP + UDP for HTTP/3). Forward it on the router.
  # Fluxer bakes it into every public URL via FLUXER_PUBLIC_ORIGIN, so
  # users open https://chat.schnozzlecat.xyz:9876. Use 443 to drop the port.
  publicPort = 9876;
  publicOrigin =
    if publicPort == 443
    then "https://${domain}"
    else "https://${domain}:${toString publicPort}";
  stateDir = "/mnt/raid/fluxer";
  dataDir = "${stateDir}/data";
  turnSecretFile = "/var/lib/fluxer-turn/secret";
  publicIpFile = "/run/fluxer-public-ip";
  turnGroup = config.systemd.services.coturn.serviceConfig.Group;

  # Fixed subnet for the compose network so LiveKit has a stable address
  # coturn can relay to. Clear of podman's defaults (10.88/16, 10.89.x/24)
  # and the WireGuard nets (10.0.0/24, 10.1.0/24).
  subnet = "10.250.0.0/24";
  livekitIp = "10.250.0.200"; # IPAM hands out .2 upwards; ~20 containers

  # aardvark-dns (compose service names) can't take port 53 on the bridge:
  # Pi-hole publishes host port 53, which also DNATs container DNS queries.
  # netavark redirects container port 53 to this port instead.
  aardvarkPort = 1153;

  podmanSocket = "unix:///run/podman/podman.sock";
  compose = "${pkgs.docker-compose}/bin/docker-compose";
  composeArgs = "--project-directory ${stateDir} -f docker-compose.yml -f docker-compose.proxy.yml --env-file .env --env-file nix.env";
  bundle = ./fluxer;
  turnMinPort = 49160;
  turnMaxPort = 49260; # one relay port per participant (~100)
in {
  virtualisation.containers.containersConf.settings.network.dns_bind_port = aardvarkPort;

  # Host Caddy: TLS via Let's Encrypt DNS-01 (Cloudflare API), so port 80 need
  # not be reachable; reverse proxy to Fluxer's plain-HTTP edge.
  sops.templates."caddy-env".content = ''
    CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare-token}
  '';

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      # Same plugin/hash as nixos/schnozzlecat.nix. If the build reports a
      # hash mismatch, replace with the reported 'got:' value.
      plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
      hash = "sha256-tubXIDCJnO2mvdnPlZclwDhNGaeeYLSt7lnni3+pXDo=";
    };
    environmentFile = config.sops.templates."caddy-env".path;
    virtualHosts."${domain}:${toString publicPort}".extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy 127.0.0.1:8080
    '';
  };
  systemd.services.caddy.after = ["sops-nix.service"];

  services.coturn = {
    enable = true;
    realm = domain;
    use-auth-secret = true;
    static-auth-secret-file = turnSecretFile;
    listening-port = 3478;
    no-tls = true;
    no-dtls = true;
    min-port = turnMinPort;
    max-port = turnMaxPort;
    no-cli = true;
    extraConfig = ''
      no-multicast-peers
      no-loopback-peers
      # RFC 6062 TCP allocations aren't needed for WebRTC
      no-tcp-relay
      # Sized for ~5 concurrent calls with several people each.
      total-quota=100
      user-quota=4
      # bytes/s per allocation (~10 Mbit/s)
      max-bps=1250000

      # The only peer clients ever need is LiveKit, which advertises our
      # public IP. The external-ip mapping appended in preStart (below)
      # rewrites that peer address to the LiveKit container. The allow list
      # is checked before the deny list.
      allowed-peer-ip=${livekitIp}
      # Don't let relayed clients reach the LAN / host / other containers.
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  # external-ip=<public>/<livekit>: coturn maps peer addresses (XOR-PEER-
  # ADDRESS) from <public> to <livekit>, so a client's "relay to
  # <public>:7882" goes straight over the podman bridge. It also maps the
  # address back in data sent to the client, so ICE sees the address it
  # expects. The relay address reported to clients stays the LAN IP, which
  # LiveKit (the only peer) can reach directly. The public IP is dynamic, so
  # it's fetched at runtime.
  systemd.services.coturn = {
    wants = ["fluxer-public-ip.service"];
    after = ["fluxer-public-ip.service"];
    preStart = lib.mkAfter ''
      if [ -s ${publicIpFile} ]; then
        echo "external-ip=$(cat ${publicIpFile})/${livekitIp}" >> /run/coturn/turnserver.cfg
      fi
    '';
  };

  # Tracks the public IPv4 (same source as ddclient). When it changes, coturn
  # (external-ip) and LiveKit (learns it via STUN at startup) are restarted.
  systemd.services.fluxer-public-ip = {
    description = "Track public IP for coturn/LiveKit";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    path = [pkgs.curl pkgs.gnused pkgs.gnugrep pkgs.coreutils pkgs.systemd];
    environment.DOCKER_HOST = podmanSocket;
    serviceConfig.Type = "oneshot";
    script = ''
      ip=""
      for _ in 1 2 3 4 5 6; do
        ip=$(curl -fsS --max-time 10 https://cloudflare.com/cdn-cgi/trace | sed -n 's/^ip=//p') || true
        echo "$ip" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' && break
        ip=""
        sleep 5
      done
      if [ -z "$ip" ]; then
        echo "could not determine public IPv4" >&2
        exit 0
      fi
      if [ "$ip" = "$(cat ${publicIpFile} 2>/dev/null)" ]; then
        exit 0
      fi
      echo "public IP is now $ip"
      echo "$ip" > ${publicIpFile}.tmp
      chmod 0644 ${publicIpFile}.tmp
      mv ${publicIpFile}.tmp ${publicIpFile}
      # At boot coturn is still waiting on this unit (inactive) and reads the
      # new file when it starts; only restart an already-running instance.
      if systemctl -q is-active coturn.service; then
        systemctl --no-block restart coturn.service
      fi
      if systemctl -q is-active fluxer.service; then
        cd ${stateDir} && ${compose} ${composeArgs} restart livekit
      fi
    '';
  };
  systemd.timers.fluxer-public-ip = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnUnitActiveSec = "10min";
      OnBootSec = "10min";
    };
  };

  systemd.tmpfiles.rules = [
    # Must exist before fluxer.service starts (WorkingDirectory).
    "d ${stateDir} 0700 root root -"
    "d /var/lib/fluxer-turn 0750 root ${turnGroup} -"
  ];

  # Generates the TURN secret once; coturn reads it, Fluxer gets it via nix.env.
  systemd.services.fluxer-turn-secret = {
    description = "Generate Fluxer TURN shared secret";
    wantedBy = ["multi-user.target"];
    before = ["coturn.service" "fluxer.service"];
    requiredBy = ["coturn.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [pkgs.openssl pkgs.coreutils];
    script = ''
      if [ ! -s ${turnSecretFile} ]; then
        umask 027
        openssl rand -hex 32 > ${turnSecretFile}
      fi
      chown root:${turnGroup} ${turnSecretFile}
      chmod 0640 ${turnSecretFile}
    '';
  };

  systemd.services.fluxer = {
    description = "Fluxer (docker compose on podman)";
    wantedBy = ["multi-user.target"];
    after = ["podman.socket" "network-online.target" "fluxer-turn-secret.service"];
    requires = ["podman.socket" "fluxer-turn-secret.service"];
    wants = ["network-online.target"];
    unitConfig.RequiresMountsFor = [stateDir];
    path = [pkgs.openssl pkgs.coreutils pkgs.gnused pkgs.gawk];
    environment.DOCKER_HOST = podmanSocket;
    # Restart when the vendored bundle changes.
    restartTriggers = [bundle];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = stateDir;
      TimeoutStartSec = "30min";
      ExecStart = "${compose} ${composeArgs} up -d --remove-orphans";
      ExecStop = "${compose} ${composeArgs} stop";
    };
    preStart = ''
      cd ${stateDir}
      install -m 0644 ${bundle}/docker-compose.yml ${bundle}/docker-compose.proxy.yml ${bundle}/Caddyfile .
      mkdir -p ca certs caddy.d/sites
      for d in postgres valkey nats meilisearch seaweedfs edge-data edge-config; do
        install -d ${dataDir}/$d
      done
      # media-proxy runs as uid 10001 and needs a writable /tmp.
      install -d -m 1777 ${dataDir}/media-proxy-tmp

      # Secrets: generated once, never overwritten.
      if [ ! -f .env ]; then
        umask 077
        hex() { openssl rand -hex 32; }
        {
          echo "FLUXER_SETTINGS_LOADED=true"
          for key in POSTGRES_PASSWORD MEILI_MASTER_KEY FLUXER_S3_SECRET_KEY FLUXER_SUDO_MODE_SECRET \
            FLUXER_CONNECTION_INITIATION_SECRET FLUXER_PROFILE_PSEUDONYM_SECRET FLUXER_GATEWAY_RPC_AUTH_TOKEN \
            FLUXER_ERLANG_COOKIE FLUXER_MEDIA_PROXY_SECRET_KEY FLUXER_ADMIN_SECRET_KEY_BASE \
            FLUXER_ADMIN_OAUTH_CLIENT_SECRET LIVEKIT_API_SECRET FLUXER_SETUP_TOKEN; do
            echo "$key=$(hex)"
          done
          echo "FLUXER_S3_ACCESS_KEY=fluxer"
          echo "LIVEKIT_API_KEY=fluxer"
          echo "FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64=$(openssl rand -base64 32)"
          echo "FLUXER_ACTIVITYPUB_SIGNING_KEY_BASE64=$(openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -outform DER | base64 | tr -d '\n')"
          openssl ecparam -name prime256v1 -genkey -noout -out vapid.pem
          echo "FLUXER_VAPID_PUBLIC_KEY=$(openssl ec -in vapid.pem -pubout -outform DER 2>/dev/null | tail -c 65 | base64 | tr '/+' '_-' | tr -d '=\n')"
          echo "FLUXER_VAPID_PRIVATE_KEY=$(openssl ec -in vapid.pem -outform DER 2>/dev/null | tail -c +8 | head -c 32 | base64 | tr '/+' '_-' | tr -d '=\n')"
          rm -f vapid.pem
        } > .env
      fi

      # Declarative settings (rewritten on every start).
      umask 077
      cat > nix.env <<EOF
      FLUXER_DOMAIN=${domain}
      FLUXER_PUBLIC_PORT=${toString publicPort}
      FLUXER_PUBLIC_ORIGIN=${publicOrigin}
      FLUXER_EDGE_BIND=127.0.0.1:8080
      FLUXER_DATA_DIR=${dataDir}
      FLUXER_SUBNET=${subnet}
      FLUXER_LIVEKIT_IP=${livekitIp}
      FLUXER_LIVEKIT_TURN_SERVERS='[{"host":"${domain}","port":3478,"protocol":"udp","secret":"$(cat ${turnSecretFile})"},{"host":"${domain}","port":3478,"protocol":"tcp","secret":"$(cat ${turnSecretFile})"}]'

      # Postgres sized for the Pi: 1-2 GB instead of the bundle's 3-5 GB.
      FLUXER_POSTGRES_MEMORY_LIMIT=2gb
      FLUXER_POSTGRES_MEMORY_RESERVATION=1gb
      FLUXER_POSTGRES_SHM_SIZE=256mb
      FLUXER_POSTGRES_SHARED_BUFFERS=512MB
      FLUXER_POSTGRES_EFFECTIVE_CACHE_SIZE=1GB
      FLUXER_POSTGRES_MAINTENANCE_WORK_MEM=128MB
      FLUXER_POSTGRES_AUTOVACUUM_WORK_MEM=64MB
      FLUXER_POSTGRES_SERVER_MAX_CONNECTIONS=100
      FLUXER_POSTGRES_MAX_PARALLEL_WORKERS=4
      EOF
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [
      publicPort # Caddy
      7881 # LiveKit TCP (podman port forwards bypass INPUT; documentation)
      3478 # TURN
    ];
    allowedUDPPorts = [
      publicPort # Caddy HTTP/3
      7882 # LiveKit UDP (see above)
      3478 # TURN
    ];
    # Relay ports: only LiveKit, over the podman bridge, talks to them.
    # aardvark-dns on its moved port (container :53 is DNAT'd to it).
    interfaces."podman+" = {
      allowedUDPPortRanges = [
        {
          from = turnMinPort;
          to = turnMaxPort;
        }
      ];
      allowedUDPPorts = [aardvarkPort];
      allowedTCPPorts = [aardvarkPort];
    };
  };
}
