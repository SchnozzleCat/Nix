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
}: let
  # Combined .NET SDKs (same 8/9/10 set as home/linus.nix). Landed here
  # because home-manager's sessionVariables aren't sourced by fish --
  # and the default shell IS fish. Framework-dependent apphost binaries
  # are exec'd *around* dotnet (e.g. `aspire run` spawns the AppHost
  # directly), so the bin/dotnet wrapper's env never reaches them; they
  # search DOTNET_ROOT for host/fxr + shared runtimes.
  dotnet-env = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
      sdk_10_0
    ];
in {
  environment.variables.DOTNET_ROOT = "${dotnet-env}/share/dotnet";

  imports = [
    ./hardware-configuration-${hostname}.nix
    ./${hostname}.nix
    inputs.noctalia.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  # Secrets (sops-nix). Decrypted at activation into /run/secrets.
  # Each host decrypts with its SSH ed25519 host key; values live in secrets.yaml.
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      openai-api-key.owner = "linus";
    };
  };

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
    "fs.inotify.max_user_watches" = 1048576;
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
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      7777
    ];
    allowedUDPPorts = [
      7777
    ];
  };

  # networking.wg-quick.interfaces.proton-de350.configFile = config.sops.secrets.wg-proton-de350.path;

  # Yubikey
  services.udev.packages = [pkgs.yubikey-personalization];
  services.pcscd.enable = true;

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };

  hardware.sane = {
    enable = true;
    openFirewall = true;
  };

  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  # Self-signed HTTPS dev certificate used by the Aspire dashboard
  # (https://aspire.dev) and other dotnet dev-certs consumers. Pinned here
  # so browsers trust https://localhost:17*. Public key only, safe to commit.
  # Regenerate if the dev cert is renewed past its notAfter (check with
  # `dotnet dev-certs https --check --trust`) by re-running:
  #   dotnet dev-certs https -ep ~/.nixos/assets/aspire-dev-cert.pem \
  #     --format PEM --no-password
  # then `sudo nixos-rebuild switch`. NOTE: security.pki.certificates only
  # reaches apps using the system CA bundle / NixOS-patched NSS (Firefox in
  # nixpkgs). Prebuilt browsers like Zen ignore it -- import into Zen's
  # profile NSS db with certutil (pkgs.nssTools) for those.
  security.pki.certificates = [
    (builtins.readFile ../assets/aspire-dev-cert.pem)
  ];

  programs.command-not-found.enable = false;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  virtualisation.containerd = {
    enable = true;
  };

  # Allow user-level systemd slices to enforce cgroup limits.
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
      openssl.out
      openssl
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
    wayland.enable = true;
    theme = "chili";
  };

  # Swaylock
  security.pam.services.swaylock = {};

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;

    # Virtual audio cable "music" that automatically forwards to the default output.
    extraConfig.pipewire."10-music-cable" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "audio.position" = ["FL" "FR"];
            "capture.props" = {
              "media.class" = "Audio/Sink";
              "node.name" = "music";
              "node.description" = "music";
              "device.description" = "music";
              "device.class" = "sound";
              "device.icon-name" = "audio-card";
              "node.virtual" = false;
            };
            "playback.props" = {
              "node.name" = "music-output";
              "node.passive" = true;
              # No target.object -> WirePlumber routes playback to the default sink.
            };
          };
        }
      ];
    };
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
  environment.sessionVariables = {
    TZDIR = "/etc/zoneinfo";
    NIXOS_OZONE_WL = "1";
  };

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

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    naps2
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
    # Lix straight from nixpkgs, per https://lix.systems/add-to-config/:
    # stable release, binary-cached on cache.nixos.org. Replaces the old
    # lix-module flake input, which was never imported by any system and
    # pulled from the flaky self-hosted git.lix.systems on every eval.
    package = pkgs.lixPackageSets.stable.lix;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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
