{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-schnozzlecat-server.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      pihole = {
        autoStart = true;
        image = "pihole/pihole:latest";
        volumes = [
          "/var/lib/pihole:/etc/pihole"
          "/var/lib/dnsmasq.d:/etc/dnsmasq.d"
        ];
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "80:80/tcp"
        ];
        environment = {
          ServerIP = "localhost";
        };
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--dns=127.0.0.1"
          "--dns=1.1.1.1"
        ];
        workdir = "/var/lib/pihole/";
      };
    };
  };

  # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "end0";
    internalInterfaces = ["wg0"];
  };
  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [53];
    allowedUDPPorts = [53 51111];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/7d2166ba-5e9a-402a-af11-8a72b31bd96a";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/8C72-148E";
    fsType = "exfat";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "tradfri"
      "govee_ble"
      "tplink"
      "tplink_tapo"
    ];
    config = {
      default_config = {};
      homeassistant = {
        name = "Home";
        latitude = "48.10372829240035";
        longitude = "11.597223701105742";
        elevation = "520";
        unit_system = "metric";
        time_zone = "Europe/Berlin";
      };
    };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.0.0.1/24"];
      listenPort = 51111;
      privateKeyFile = "/home/linus/wireguard-keys/private.key";
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
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    trusted-users = ["linus"];
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  networking.hostName = "schnozzlecat-server";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  security.sudo.wheelNeedsPassword = false;

  users.users = {
    linus = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker"];
      initialPassword = "password";
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

  # networking.hostName = "nixos"; # Define your hostname.

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
