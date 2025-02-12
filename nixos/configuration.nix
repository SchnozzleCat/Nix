# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  imports = [
    ./hardware-configuration-${hostname}.nix
    ./${hostname}.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.displayManager.autoLogin = {
    enable = true;
    user = "linus";
  };

  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
  };

  # Yubikey
  services.udev.packages = [pkgs.yubikey-personalization];
  services.pcscd.enable = true;

  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  programs.command-not-found = {
    enable = true;
    dbPath = "${inputs.programs-db}/programs.sqlite";
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.groups.plugdev = {
    name = "plugdev";
    members = ["linus"];
  };

  hardware.keyboard.zsa.enable = true;

  # Allow flashing of ZSA firmware.
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # GPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  programs.nix-ld.enable = true;

  # TPM
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # USB
  services.udisks2.enable = true;
  hardware.logitech.wireless.enable = true;

  # SDDM
  services.displayManager.sddm = {
    enable = true;
    settings.Theme.FacesDir = "${../secrets/avatars}";
    wayland.enable = true;
    theme = "chili";
  };

  # Swaylock
  security.pam.services.swaylock = {};

  # Autostart
  systemd.user.services = {
    polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Localization
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  hardware.opentabletdriver.enable = true;

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = ["JetBrainsMono NerdFont"];
      emoji = ["Font Awesome 6 Free"];
    };
  };

  security.polkit = {
    enable = true;
  };

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    linus = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "audio" "docker" "corectrl" "libvirtd" "tss" "storage"];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    alsa-utils
    brightnessctl
    hyprpaper
    yubikey-manager
    pinentry-gnome3
    docker-compose
    sshfs
    firewalld-gui
    gamescope
    (sddm-chili-theme.overrideAttrs (old: {
      src = builtins.fetchGit {
        url = "file:///home/linus/.nixos/repos/sddm-chili";
        ref = "master";
        rev = "4e662978bf69daa555cd418e5ee3b6444be7115c";
      };
    }))
  ];

  # Shell
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  # Misc
  programs.dconf.enable = true;

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

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.master-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Configure your nixpkgs instance
    config = {
      # packageOverrides = pkgs: {
      #   steam = pkgs.steam.override {
      #     extraPkgs = pkgs:
      #       with pkgs; [
      #         xorg.libXcursor
      #         xorg.libXi
      #         xorg.libXinerama
      #         xorg.libXScrnSaver
      #         libpng
      #         libpulseaudio
      #         libvorbis
      #         stdenv.cc.cc.lib
      #         libkrb5
      #         keyutils
      #       ];
      #   };
      # };
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # # This setups a SSH server. Very important if you're setting up a headless system.
  # # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     # Forbid root login through SSH.
  #     PermitRootLogin = "no";
  #     # Use keys only. Remove if you want to SSH using password (not recommended)
  #     PasswordAuthentication = false;
  #   };
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
