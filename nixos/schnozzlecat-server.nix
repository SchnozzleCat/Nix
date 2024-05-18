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

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    allowedUDPPorts = [51111];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = ["10.100.0.1/24"];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/linus/wireguard-keys/private.key";

      peers = [
        # List of allowed peers.
        {
          # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "Jq90boTS2KFk0NDDSTPuQV6wKUF9PjRMQPzbsHdfe0U=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = ["10.100.0.2/32"];
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
    passwordAuthentication = false;
    ports = [
      6969
    ];
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
