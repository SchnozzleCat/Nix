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
      waybar
      wl-clipboard
      pavucontrol
      pyprland

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
      wtype
      ripgrep
      fzf
      xwaylandvideobridge
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
      ranger
      shell_gpt

      # Files

      # Games
      steam
      steam-run
      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
          gamescope
        ];
      })

      # Misc
      obsidian
      helvum
      spotify
      whatsapp-for-linux
      cinnamon.warpinator
      discord
      jellyfin-media-player
      texlive.combined.scheme-full
      jabref
      (pkgs.ollama.override {
        llama-cpp = pkgs.llama-cpp.override {
          openblasSupport = false;
        };
      })

      # Shell Scripts
      (writeShellApplication {
        name = "power-menu";
        text = import ./scripts/power-menu.nix;
      })
      (writeShellApplication {
        name = "record-screen";
        text = import ./scripts/record-screen.nix {inherit pkgs;};
      })
      (writeShellApplication {
        name = "translate-en-to-de";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="EN -> DE: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.translate-shell}/bin/trans -no-ansi en:de "$text" | fuzzel --dmenu --width=50 --lines=20
        '';
      })
      (writeShellApplication {
        name = "translate-de-to-en";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="DE -> EN: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.translate-shell}/bin/trans -no-ansi de:en "$text" | fuzzel --dmenu --width=50 --lines=20
        '';
      })
      (writeShellApplication {
        name = "synonym";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="Synonym: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.wordnet}/bin/wn "$text" -synsn -synsv -synsa -synsr | fuzzel --dmenu --width=50 --lines=20
        '';
      })
    ];
  };

  programs.mpv = {
    enable = true;
    config = {
      audio-device = "pulse";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
    previewer.source = pkgs.writeShellScript "scope.sh" ''
      pistol "$1"
    '';
    commands = with pkgs; {
      dragon-out = ''%${xdragon}/bin/xdragon -a -x "$fx"'';
      open = ''''${{rifle "$f"}}'';
      copy-path = ''&{{echo -n "$f" | wl-copy}}'';
      mkdir = ''
        %{{
          printf "Directory Name > "
          read DIR
          mkdir $DIR
        }}
      '';
      mkfile = ''
        %{{
          printf "File Name > "
          read FILE
          touch $FILE
        }}
      '';
      rename = ''%[ -e $1 ] && printf "file exists" || mv "$f" "$1"'';
      on-select = ''
        &{{
          lf -remote "send $id set statfmt \"$(eza -ld --color=always "$f")\""
        }}'';
      on-cd = ''
        &{{
          export STARSHIP_SHELL=
          fmt="$(starship prompt)"
          lf -remote "send $id set promptfmt \"$fmt\""
        }}'';
      fzf_find = ''
        ''${{
            res="$(rg --files | fzf --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                lf -remote "send $id $cmd \"$res\""
            fi
        }}
      '';
      fzf_exact = ''
        ''${{
            res="$(rg --files | fzf --exact --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                lf -remote "send $id $cmd \"$res\""
            fi
        }}
      '';
    };
    keybindings = {
      yd = "dragon-out";
      yy = "copy";
      yp = "copy-path";
      y = "";
      dd = "cut";
      d = "";
      dD = "delete";
      pp = ": paste; clear";
      S = "push :shell<enter>$SHELL<enter>";
      p = "";
      t = "";
      tt = "mkfile";
      td = "mkdir";
      a = "push :rename<space>";
      "<c-f>" = "fzf_find";
      "<c-e>" = "fzf_exact";
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
  home.file.".config/ranger/rifle".source = ./rifle.nix;
  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = ["scratchpads", "expose", "magnify"]

    [scratchpads.term]
    command = "foot -a foot-float"
    animation = "fromBottom"
    margin = 50
    unfocus = "hide"

    [scratchpads.ncspot]
    command = "foot -a foot-ncspot ncspot"
    animation = "fromBottom"
    margin = 50
    unfocus = "hide"

    [scratchpads.volume]
    command = "pavucontrol"
    animation = "fromRight"
  '';

  programs.waybar = {
    enable = true;
    settings = import ./waybar-config.nix;
    style = import ./waybar-style.nix;
  };

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
        alpha = 0.8;
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
        background = "${colors.base00}aa";
        selection = "${colors.base01}aa";
        border = "${colors.base08}ff";
      };
      border = {
        radius = 5;
        width = 2;
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

  services.fnott = {
    enable = true;
    settings = {
      main = {
        background = "${colors.base00}ff";
        icon-theme = "Tela-circle-dark";
        selection-helper = "fuzzel --dmenu";
        border-size = 1;
        border-color = "${colors.base08}ff";
        title-color = "${colors.base0A}ff";
        body-color = "${colors.base05}ff";
        body-font = "JetBrainsMono Nerd Font";
        title-font = "JetBrainsMono Nerd Font";
        output = "DP-1";
      };
    };
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
      export OPENER=rifle
      export EDITOR=nvim
      export OPENAI_API_KEY_DIR=${../secrets/keys/openapi.gpg}
      set -g fish_greeting
      task list
    '';
    shellAliases = {
      gpt = "DEFAULT_MODEL=gpt-4-1106-preview OPENAI_API_KEY=$(gpg -q --decrypt $OPENAI_API_KEY_DIR) sgpt";
      pi-hdd = ''sshfs -o sftp_server="/usr/bin/sudo /usr/lib/openssh/sftp-server" -p 6969 pi@192.168.200.41:/mnt/hdd ~/Mounts/hdd'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/";
      home-rebuild = "home-manager switch --flake ~/.nixos/";
      ls = "eza -la";
      cat = "bat";
      # which-gpu = ''glxinfo| grep -E "OpenGL vendor|OpenGL renderer"'';
      # docker-stop-containers = "docker stop $(docker ps -a -q)";
      pi = "ssh pi@192.168.200.41 -p 6969";
      # alert = "paplay /usr/share/sounds/freedesktop/stereo/complete.oga";
      # boot-win11 = ''sudo grub2-reboot "Windows Boot Manager (on /dev/nvme1n1p1)" && reboot'';
      # nvim-unity = "nvim --listen /tmp/nvimunity";
      # enable-displays = ''swaymsg output "DP-2" enable && swaymsg output "DP-3" enable && swaymsg output "HDMI-A-1" enable'';
      # disable-displays = ''swaymsg output "DP-2" disable && swaymsg output "DP-3" disable && swaymsg output "HDMI-A-1" disable'';
      rm = "rm -I";
      mv = "mv -i";
      untar = "tar -xvf";
      zj = "zellij -l compact";
      tmux = "zellij -l compact";
      cd = "z";
      ranger = "lf";
    };
  };
}
