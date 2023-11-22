{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  ...
}: let
  colors = config.colorScheme.colors;
in {
  imports = [
    ./home.nix
    ./neovim.nix
  ];

  gtk = {
    enable = true;
    theme = {
      package = pkgs.layan-gtk-theme;
      name = "Layan-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 1;
    };
    iconTheme = {
      package = pkgs.tela-circle-icon-theme;
      name = "Tela-circle-dark";
    };
  };

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    packages = with pkgs; [
      # OS
      fnott
      waybar
      wl-clipboard
      clipman
      pavucontrol
      pyprland
      swaylock-effects

      # Web
      brave
      qbittorrent

      # Dev
      unityhub
      jetbrains.rider
      jetbrains.datagrip
      sublime-merge
      lazygit

      # Utilities
      lm_sensors
      solaar
      grim
      slurp
      swappy
      wtype
      ripgrep
      fzf
      git-crypt

      # Terminal
      eza
      bat
      zellij
      du-dust
      ncspot
      neofetch
      cbonsai
      pipes
      pistol
      imv
      taskwarrior-tui

      # Files

      # Games
      steam
      steam-run
      (lutris.override {
        extraPkgs = pkgs: [
          wine
          winetricks
        ];
      })

      # Misc
      obsidian
      helvum
      obs-studio
      whatsapp-for-linux
      cinnamon.warpinator
      discord
      jellyfin-media-player
      texlive.combined.scheme-full

      # Shell Scripts
      (writeShellApplication {
        name = "power-menu";
        text = import ./scripts/power-menu.nix;
      })
    ];
  };

  programs.git = {
    enable = true;
    userName = "SchnozzleCat";
    userEmail = "linus@schnozzlecat.xyz";
    signing = {
      key = "537B FDDE 066D 4D00 E6B1  5D90 21FB 9DA7 99F8 7226";
      signByDefault = true;
    };
  };

  programs.lf = {
    enable = true;
    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
    };
    commands = with pkgs; {
      dragon-out = ''%${xdragon}/bin/xdragon -a -x "$fx"'';
    };
    keybindings = {
      "do" = "dragon-out";
      "<enter>" = "open";
    };
  };

  programs.taskwarrior = {
    enable = true;
  };

  services = {
    gammastep = {
      enable = true;
      tray = true;
      latitude = 48.10373065283809;
      longitude = 11.596935278032168;
    };
  };

  home.file.".config/lf/icons".source = ./lf-icons.nix;
  home.file.".config/waybar".source = ./waybar;
  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = ["scratchpads", "expose", "magnify"]

    [scratchpads.term]
    command = "foot -a foot-float"
    animation = "fromBottom"
    margin = 50
    unfocus = "hide"

    [scratchpads.volume]
    command = "pavucontrol"
    animation = "fromRight"
  '';

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        source = ./pub.asc;
      }
    ];
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=10";
      };
      cursor = {
        color = "1A1826 D9E0EE";
      };
      colors = {
        alpha = 0.95;
        foreground = colors.base05;
        background = colors.base00;
        regular0 = colors.base02;
        regular1 = colors.base08;
        regular2 = colors.base0B;
        regular3 = colors.base09;
        regular4 = colors.base0D;
        regular5 = colors.base0E;
        regular6 = colors.base0C;
        regular7 = colors.base06;
        bright0 = colors.base02;
        bright1 = colors.base08;
        bright2 = colors.base0B;
        bright3 = colors.base09;
        bright4 = colors.base0D;
        bright5 = colors.base0E;
        bright6 = colors.base0C;
        bright7 = colors.base06;
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "ayu";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      vim_keys = true;
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        width = 35;
        font = "JetBrainsMono Nerd Font:size=16";
        icon-theme = "Tela-circle-dark";
        line-height = 25;
        fields = "name,generic,comment,categories,filename,keywords";
        terminal = "foot -e";
        prompt = "       ";
        layer = "overlay";
      };
      colors = {
        background = "${colors.base00}ee";
        selection = "${colors.base04}fa";
        border = "${colors.base08}ff";
      };
      border = {
        radius = 1;
      };
      dmenu = {
        exit-immediately-if-empty = "yes";
      };
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zathura = {
    enable = true;
    options = {
      recolor = 1;
      recolor-lightcolor = "#1E1D2D";
      recolor-darkcolor = "#838796";
      default-bg = "#838796";
      selection-clipboard = "clipboard";
    };
    mappings = {
      "<C-z>" = "recolor";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      task list
    '';
    shellAbbrs = {
      rebuild-os = "sudo nixos-rebuild switch --flake ~/.nixos/";
      rebuild-home = "home-manager switch --flake ~/.nixos/";
      ls = "eza -la";
      cat = "bat";
      which-gpu = ''glxinfo| grep -E "OpenGL vendor|OpenGL renderer"'';
      cleargit = "~/Applications/cleargitcredentials.sh";
      docker-stop-containers = "docker stop $(docker ps -a -q)";
      pi = "ssh pi@192.168.200.41 -p 6969";
      alert = "paplay /usr/share/sounds/freedesktop/stereo/complete.oga";
      boot-win11 = ''sudo grub2-reboot "Windows Boot Manager (on /dev/nvme1n1p1)" && reboot'';
      nvim-unity = "nvim --listen /tmp/nvimunity";
      enable-displays = ''swaymsg output "DP-2" enable && swaymsg output "DP-3" enable && swaymsg output "HDMI-A-1" enable'';
      disable-displays = ''swaymsg output "DP-2" disable && swaymsg output "DP-3" disable && swaymsg output "HDMI-A-1" disable'';
      rm = "rm -I";
      mv = "mv -i";
      untar = "tar -xvf";
      zj = "zellij -l compact";
      tmux = "zellij -l compact";
      cd = "z";
    };
  };
}
