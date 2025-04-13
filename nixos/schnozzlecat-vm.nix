{
  config,
  pkgs,
  lib,
  ...
}: let
  godot4-mono-schnozzlecat =
    (pkgs.callPackage ../pkgs/godot4-mono-schnozzlecat {}).overrideAttrs
    (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "SchnozzleCat";
        repo = "godot";
        rev = "4c575e3f3801bfc615ebf9c923b587f1548f5dd6";
        sha256 = "sha256-t0HuAwuylNIHFv+zZzWWKK9axno9wDpRbIhtgFaVJ9Q=";
      };
    });
in {
  boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  users.users = {
    linus = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "password";
      createHome = true;
      home = "/home/linus";
    };
  };

  environment.systemPackages = with pkgs; [
    foot
    git
    lazygit
    dust
    btop
    dotnetCorePackages.sdk_9_0
    (writeShellApplication {
      name = "start";
      text = ''
        nix run home-manager/master -- switch --flake github:SchnozzleCat/Nix#linus@schnozzlecat-vm
      '';
    })
  ];

  programs.hyprland.enable = true;

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    gamescopeSession.enable = true; # Enable GameScope session
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
          gamescope
        ];
    };
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 12288;
      cores = 8;
      graphics = true;
      diskSize = 20000;
      sharedDirectories = {
        "home" = {
          source = "/home/linus/Mounts/vm";
          target = "/home/linus";
        };
        "atlw" = {
          source = "/home/linus/Repositories/AfterTheLastWord";
          target = "/home/linus/Repositories/AfterTheLastWord";
        };
      };
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
