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
    ../modules/home-manager/pi-sandbox-netns.nix
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

  services.blueman.enable = true;

  programs.fuse.enable = true;

  # Link /bin/
  services.envfs.enable = true;

  # Networking
  networking.hostName = hostname;
  networking.hosts."10.200.1.2" = ["sandbox"];
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      7777
    ];
    allowedUDPPorts = [
      7777
    ];
    interfaces."veth-pisb-h".allowedTCPPorts = [5432 5433 5434 6379 6380];
  };

  # networking.wg-quick.interfaces.proton-de350.configFile = "/home/linus/.nixos/secrets/wireguard/proton-de350.conf";

  # Yubikey
  services.udev.packages = [pkgs.yubikey-personalization];
  services.pcscd.enable = true;

  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  security.pki.certificates = [
    "-----BEGIN CERTIFICATE-----
MIID0TCCArmgAwIBAgIHXJ+Tj8cL8zANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQD
Ewlsb2NhbGhvc3QwHhcNMjYwNDE1MjEzMjMzWhcNMjcwNDE1MjEzMjMzWjAUMRIw
EAYDVQQDEwlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDSPyD8DAQpuYnRrVDJp1hjv2Qddam2NrMrdGBk5mFXTYyB9XxII+f9WHt55ejz
DPV3wRou7tyr8Izsp12AEOXlFJQliKLVr/akDzsSwffjw6ihis8zDSH9TynEquI/
NjK6tmYGK95ZCBHqtZV+n6RlL0tg/4DZC8QPaz5qgnkXTjJhX8qOOfMxmkaLw92Q
6UA0j9uSX4JR/Uq47n5UguVo14h6yg4+BDzVeXxiwK4ZSFyoiUt6yDDvKvCiKRPl
WZWGeYhEKY1alVojt7RJnw0inH7YNykeQTSfGN7IuAPpf71fqMwWYFxj6nKp8euv
cf/ANlvgd3iJWPlZLXqjK+KZAgMBAAGjggEmMIIBIjAMBgNVHRMBAf8EAjAAMA4G
A1UdDwEB/wQEAwIFoDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDATCBgAYDVR0RAQH/
BHYwdIIJbG9jYWxob3N0gg8qLmRldi5sb2NhbGhvc3SCDiouZGV2LmludGVybmFs
ghRob3N0LmRvY2tlci5pbnRlcm5hbIIYaG9zdC5jb250YWluZXJzLmludGVybmFs
hwR/AAABhxAAAAAAAAAAAAAAAAAAAAABMA8GCisGAQQBgjdUAQEEAQYwKQYDVR0O
BCIEIB7058Kt1Yyghis0S9qRcQPBo28OLf3o0BnDUTTQ43hhMCsGA1UdIwQkMCKA
IB7058Kt1Yyghis0S9qRcQPBo28OLf3o0BnDUTTQ43hhMA0GCSqGSIb3DQEBCwUA
A4IBAQCd7H6gKmxXF3PVKd92wkTaI94PULnOtg4Xhus/KNcIcUsCaExC7YyTdIts
olXRYvHMYMKB2JEX5O9vKMz2nm3tI7KMYdLAvhp0V4Ik8Lh1+6/0yf9Ic1J/ghT1
h/cn7pEwPRyuRtnTAfgm0ghplgMzOkjF6q3ynOhQUOhME7F06J2fWlUeu/ifx9yU
gTYfuJO6F9Cl5lRh525tSepHRAM2nYrKeicZZW5WT+9FvGLHxrHlzsaIMNMyBD73
Oj729pCV7284H6Dm1fAkbWCjiSZjH5H+dydUV1XTbVM1psn97QtJQxGApLXg6Ewy
R1tH9/wg2FSXDNZKCTJ5iSfZLBrL
-----END CERTIFICATE-----"
  ];

  programs.command-not-found.enable = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  services.pi-sandbox-netns = {
    enable = true;
    allowedDomains = [
      # AI/LLM APIs
      "api.anthropic.com"
      ".openai.com"
      ".opencode.ai"

      # Git hosting
      ".github.com"
      ".githubusercontent.com"
      ".gitlab.com"
      ".bitbucket.org"

      # Package registries
      ".npmjs.org"
      ".npmjs.com"
      ".yarnpkg.com"
      ".pypi.org"
      ".pythonhosted.org"
      ".crates.io"
      ".rubygems.org"
      ".nuget.org"
      ".azureedge.net"
      ".blob.core.windows.net"
      ".pkg.dev"
      ".registry.npmjs.org"

      # Project management
      ".linear.app"

      # Documentation / common dev resources
      ".stackoverflow.com"
      ".stackexchange.com"
      ".docs.rs"
      ".doc.rust-lang.org"
      ".developer.mozilla.org"
      ".nodejs.org"
      ".nixos.org"
      ".nixpkgs.org"
      ".nix-community.org"
      ".cachix.org"
      ".cache.nixos.org"

      # CDNs commonly used by the above
      ".cloudflare.com"
      ".cloudflare.net"
      ".cloudfront.net"
      ".fastly.net"

      ".auth0.com"
      ".auth0edge.com"
      "t-staging.eu.auth0.com"
    ];
    allowHostPorts = [5432 5433 5434 6379 6380];
  };

  virtualisation.containerd = {
    enable = true;
  };

  # Allow user-level systemd slices (e.g. pi-sandbox) to enforce cgroup limits.
  # Without this, MemoryMax/CPUQuota in user slices are silently ignored.
  services.logind.settings.Login.Delegate = "memory pids cpu";

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
    pinentryPackage = pkgs.pinentry-all;
  };

  programs.yubikey-touch-detector = {
    enable = true;
    libnotify = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      libGL
      zlib
      lzlib
      libxcrypt
      glib
      fuse3
      nspr
      cups.lib
      libdrm
      gdk-pixbuf
      gtk3
      pango
      cairo
      at-spi2-atk
      fuse
      icu
      icu.dev
      fontconfig
      freetype
      nss
      dbus.lib
      krb5.lib
      openssl.dev
      curl
      expat
      vulkan-loader
      libGL
      speechd
      libgbm
      libxcomposite
      libxdamage
      libx11
      libxcursor
      libxinerama
      libxext
      libxrandr
      libxrender
      libxi
      libxfixes
      libxcb.out
      libxscrnsaver
      libxfixes
      libxshmfence
      libxtst
      libnotify
      libxkbcommon
      alsa-lib
      mono
      wayland-scanner
      wayland
      libdecor
    ];
  };

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
    jack.enable = true;
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
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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
      noto-fonts-color-emoji
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
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "podman"
        "corectrl"
        "libvirtd"
        "tss"
        "storage"
        "i2c"
        "gamemode"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    pwvucontrol
    alsa-utils
    brightnessctl
    hyprpaper
    yubikey-manager
    pinentry-gnome3
    podman-compose
    sshfs
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
          libxcursor
          libxi
          libxinerama
          libxscrnsaver
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
      substituters = [
        "https://hyprland.cachix.org"
        "https://nixos-raspberrypi.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      ];
      trusted-users = ["linus"];
    };
    # Opinionated: disable channels
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

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
