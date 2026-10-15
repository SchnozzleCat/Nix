{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
  boot.kernel.sysctl."dev.raid.speed_limit_max" = 300000;
  boot.swraid.enable = true;
  # RPi vendor kernel builds no TPM modules, so initrd TPM2 support can't
  # resolve tpm-crb/tpm-tis and breaks modules-shrunk (nixos-hardware#858,
  # nixpkgs#344963). The Pi has no TPM anyway.
  boot.initrd.systemd.tpm2.enable = lib.mkForce false;
  boot.loader.grub.device = "nodev";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Secrets (decrypted from secrets.yaml at activation)
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      cloudflare-token = {};
      cloudflared-credentials = {};
      wg-rpi5-private = {};
      wg-jellyfin-private = {};
    };
  };

  services.ddclient = {
    enable = true;
    interval = "10min";
    usev4 = "webv4,webv4='https://cloudflare.com/cdn-cgi/trace', web-skip='ip='";
    ssl = true;
    passwordFile = config.sops.secrets.cloudflare-token.path;
    extraConfig = ''
      protocol=cloudflare
      zone=schnozzlecat.xyz
      username=token
      trace.schnozzlecat.xyz
    '';
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Host directories for container bind mounts (oci-containers does not
  # create these; podman fails with "statfs ...: no such file or directory")
  systemd.tmpfiles.rules = [
    "d /var/lib/home-assistant 0755 root root -"
    "d /var/lib/jellyfin 0755 root root -"
    "d /var/lib/jellyfin/config 0755 root root -"
    "d /var/lib/jellyfin/cache 0755 root root -"
    "d /var/lib/pihole 0755 root root -"
    "d /var/lib/dnsmasq.d 0755 root root -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      pihole = {
        autoStart = true;
        # Fully-qualified: podman resolves short names only if
        # virtualisation.containers.registries.settings defines
        # unqualified-search.registries, which the default config no
        # longer does (26.11 containers-common).
        image = "docker.io/pihole/pihole:latest";
        volumes = [
          "/var/lib/pihole:/etc/pihole"
          "/var/lib/dnsmasq.d:/etc/dnsmasq.d"
        ];
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "1337:80/tcp"
        ];
        environment = {
          ServerIP = "localhost";
        };
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--dns=127.0.0.1"
          "--dns=1.1.1.1"
        ];
      };
      home-assistant = {
        autoStart = true;
        image = "docker.io/homeassistant/home-assistant:latest";
        volumes = [
          "/run/dbus:/run/dbus:ro"
          "/var/lib/home-assistant:/config"
        ];
        environment = {
          TZ = "Europe/Berlin";
        };
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
      };
      jellyfin = {
        autoStart = true;
        image = "docker.io/jellyfin/jellyfin:latest";
        volumes = [
          "/var/lib/jellyfin/config:/config"
          "/var/lib/jellyfin/cache:/cache"
          "/mnt/raid/media:/media"
        ];
        ports = [
          "8096:8096/tcp"
          "7359:7359/udp"
        ];
      };
      # nextcloud-aio-mastercontainer = {
      #   autoStart = true;
      #   image = "ghcr.io/nextcloud-releases/all-in-one:latest";
      #   volumes = [
      #     "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
      #     "/var/run/docker.sock:/var/run/docker.sock:ro"
      #   ];
      #   ports = [
      #     "80:80"
      #     "8080:8080"
      #     "8443:8443"
      #   ];
      #   environment = {
      #     NEXTCLOUD_DATADIR = "/mnt/raid/nextcloud";
      #     SKIP_DOMAIN_VALIDATION = "true";
      #     APACHE_PORT = "11000";
      #     APACHE_IP_BINDING = "0.0.0.0";
      #   };
      #   extraOptions = [
      #     "--sig-proxy=false"
      #   ];
      # };
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels."729e667c-0deb-4724-8614-97f8827279db" = {
      credentialsFile = config.sops.secrets.cloudflared-credentials.path;
      default = "http_status:404";
    };
  };

  # systemd.services.foundry = {
  #   wantedBy = [ "multi-user.target" ];
  #   enable = true;
  #   serviceConfig = {
  #     User = "linus";
  #     Group = "users";
  #     ExecStart = ''${pkgs.nodejs_22}/bin/node /home/linus/foundry/resources/app/main.js --dataPath=/mnt/ssd/files/shared/foundrydata --port=42069'';
  #   };
  # };

  # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "end0";
    internalInterfaces = ["wg0" "wg1"];
  };
  # SMB share of /mnt/raid for Windows hosts
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server min protocol" = "SMB2";
      };
      raid = {
        path = "/mnt/raid/sarah";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "linus";
        # raid is root-owned; read/write everything as root
        "force user" = "root";
        "force group" = "root";
      };
    };
  };

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      53
      8123
    ];
    allowedUDPPorts = [
      53
      51111
      51112
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  fileSystems."/mnt/raid" = {
    device = "/dev/disk/by-uuid/72767823-2106-41a6-8a38-448c6fe46682";
    fsType = "ext4";
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/7d2166ba-5e9a-402a-af11-8a72b31bd96a";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/8C72-148E";
    fsType = "exfat";
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.0.0.1/24"];
      listenPort = 51111;
      privateKeyFile = config.sops.secrets.wg-rpi5-private.path;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o end0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o end0 -j MASQUERADE
      '';
      peers = [
        {
          publicKey = "Bsd/uDa5T6AZbdwUYjDJkI2YQdph/Mj5f0t8cnyJdxo=";
          allowedIPs = ["10.0.0.2/32"];
        }
      ];
    };
    wg1 = {
      ips = ["10.1.0.1/24"];
      listenPort = 51112;
      # wg-jellyfin-private is decrypted by sops-nix at activation into
      # /run/secrets/wg-jellyfin-private (see sops.secrets above).
      privateKeyFile = config.sops.secrets.wg-jellyfin-private.path;

      # No NAT or forwarding needed, since traffic is local to the Pi
      postSetup = ''
        # Allow only Jellyfin traffic in via wg1. No DNAT needed: the Jellyfin
        # container publishes 0.0.0.0:8096 on the host, so INPUT + docker-proxy
        # already delivers traffic to 10.1.0.1:8096. (DNAT to 127.0.0.1 gets
        # dropped as a martian packet on non-loopback interfaces.)
        ${pkgs.iptables}/bin/iptables -A INPUT -i wg1 -p tcp --dport 8096 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A INPUT -i wg1 -j DROP
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D INPUT -i wg1 -p tcp --dport 8096 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D INPUT -i wg1 -j DROP
      '';

      peers = [
        {
          publicKey = "261oRRpK/yeyXfcB34djnKVMfyLlk3pMyL/TNaGa4F4=";
          allowedIPs = ["10.1.0.2/32"];
        }
        {
          publicKey = "Fb6bxBN6kFT9zmcY0T9Zx2HF9FVIF8ctart+g+XVCE8=";
          allowedIPs = ["10.1.0.3/32"];
        }
      ];
    };
  };

  # Restrict wg1 clients to Jellyfin tcp/8096 only.
  # NOTE: we're on podman, not docker, so there is no DOCKER-USER chain.
  # The equivalent hook is the FORWARD chain scoped to the podman bridge
  # (netavark's default bridge for the rootful "podman" network is podman0).
  # Container-published ports are DNAT'd in PREROUTING, so client traffic to
  # Jellyfin traverses FORWARD (in-interface stays wg1), while traffic to
  # host-network services (e.g. pihole) stays in INPUT (covered by the
  # wg1 postSetup rules above).
  systemd.services.wg1-jellyfin-guard = {
    description = "Restrict wg1 WireGuard clients to Jellyfin tcp/8096 in podman FORWARD";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = ''
        ${pkgs.iptables}/bin/iptables -w -D FORWARD -i wg1 -o podman0 -p tcp --dport 8096 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -w -D FORWARD -i wg1 -o podman0 -j DROP || true
      '';
    };
    script = ''
      ${pkgs.iptables}/bin/iptables -w -C FORWARD -i wg1 -o podman0 -p tcp --dport 8096 -j ACCEPT 2>/dev/null || \
        ${pkgs.iptables}/bin/iptables -w -I FORWARD 1 -i wg1 -o podman0 -p tcp --dport 8096 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -w -C FORWARD -i wg1 -o podman0 -j DROP 2>/dev/null || \
        ${pkgs.iptables}/bin/iptables -w -I FORWARD 2 -i wg1 -o podman0 -j DROP
    '';
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = ["linus"];
  };

  environment.systemPackages = with pkgs; [
    git
    cloudflared
    neovim
    wireguard-ui
  ];

  networking.hostName = "schnozzlecat-server";

  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings.AutoConnect = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # Required for users.users.linus.shell = fish below: installs fish
  # system-wide and wires the nix PATH dirs into login shells.
  programs.fish.enable = true;

  users.users = {
    linus = {
      isNormalUser = true;
      # Matches the desktop (users.defaultUserShell = pkgs.fish there); the
      # actual config (starship, aliases) comes from home/terminal.nix via
      # hosts/rpi5/home.nix.
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "podman"
      ];
      hashedPassword = "$6$0rMCuSINeEd6ATar$d1xHn4kxrVfL359Pn.F8Ig8B.u5nCg5xE35b7qiOBfEK5ZOCP09RV/sad8HqIzGn7s8d118PLE4ydQLcxKIYv.";
      createHome = true;
      home = "/home/linus";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3tGusi1VdNxad/qMykPp5l8aHMivjP9qUfKZ7uwBNh0aLtMvT8qGBam/TQMXoIrIvCq9K/hQR2LetsQ/+NmVdMS6Ejt1XGP90N0AoMIUbmMOF61JgUJv5NYS/O+7iEgAlVoyGylznufiaDk0pFrBKWVLHYsQASta5aZsnSdL1xTI5fEhjdLZpOslOStI43yY5IdsAkOpjcN6Z1eirTz0Ztft3bM0uNwNERMGHJ98EOsTMXBaTmU0js2q5el/9d08Y3mJ+5RQqm22hK+xFBdTIt5prvOO+sl6ywk/itCkfeDwKX2T3fhmEXwzS/83erRPvTrYZmguF541fHsYehFhyDWI+UE2enaSe6mXAY79dphajy1dIhph/uF18Im3mA5zHyCTrPPt+0SuneAPrnZCUagUB0QY15TD7LI/CcN+MxZazQULdX+Xsg4LC4QOg+1nPNVPosIXiwNLzGmGcow4LyUuUhRbz3UwyVMj6SKyVdXk9dc+8xGladq0GL9G+7Eg8cz1xzZOa4DzDc40Mk85EsNOWZqltgt+jTuGnIOS377U0nlmqpUURyu1jOQxylQQb7J0ESPiwvP/lb2q/GPTYDuYcslTPYoCSWd2LX5BGB5mAvQ9l9ocu26DZWB0sGp/kw13f2RxC7v7OEwvlNHD+2Vlokzhr0HyZasm0oV2y/w== openpgp:0x957E5326"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    ports = [
      6969
    ];
  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

  system.stateVersion = "25.05"; # Did you read the comment?
}
