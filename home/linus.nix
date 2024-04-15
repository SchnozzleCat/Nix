{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  master,
  ...
}: let
  colors = config.colorScheme.palette;
in {
  imports = [
    ./home.nix
    ./neovim.nix
  ];

  gtk = {
    enable = true;
    gtk2.extraConfig = ''
      gtk-error-bell = 0
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
    '';
    gtk3.extraConfig = {
      gtk-error-bell = 0;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    gtk4.extraConfig = {
      gtk-error-bell = 0;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlay
  ];

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      # OS
      wl-clipboard
      pavucontrol
      pyprland
      wally-cli

      # Web
      brave
      qbittorrent

      # Dev
      unityhub
      (pkgs.buildEnv {
        name = "combinedSdk";
        paths = [
          (with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_6_0
              sdk_7_0
              sdk_8_0
            ])
        ];
      })
      # godot4-mono
      sublime-merge
      lazygit
      jetbrains.rider
      jetbrains.datagrip
      podman-tui
      ctop
      android-studio
      jdk17

      (buildDotnetGlobalTool {
        pname = "dotnet-csharpier";
        version = "0.26.7";
        nugetName = "CSharpier";
        nugetSha256 = "sha256-QVfbEtkj41/b8urLx8X274KWjawyfgPTIb9HOLfduB8=";
      })
      gdtoolkit

      # Utilities
      lm_sensors
      solaar
      wtype
      ripgrep
      fzf
      git-crypt
      neovim-remote
      zip
      unzip
      wget
      cabextract
      insomnia

      # Terminal
      eza
      bat
      du-dust
      neofetch
      cbonsai
      pipes
      pistol
      imv
      shell_gpt

      # Files

      # Games
      steam-run
      steam-tui
      steamcmd
      protonup-qt
      protontricks
      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
          gamescope
          mesa
        ];
      })
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      # runelite

      # Misc
      obsidian
      helvum
      easyeffects
      spotify
      cinnamon.warpinator
      (vesktop.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "Vencord";
          repo = "Vesktop";
          rev = "d0ff6192cbf81f1a0b497e16dff9ac7c23616436";
          hash = "sha256-/qd++djD5LQaDzxslAA55A6jZHCT6NLQ+RYofqn1x28=";
        };
      }))
      jellyfin-media-player
      jellyfin-mpv-shim
      mpv
      mpv-shim-default-shaders
      # texlive.combined.scheme-full
      jabref
      ollama
      distrobox
      # wonderdraft
      krita
      aseprite
      vscode.fhs
      protonvpn-gui
      github-copilot-cli

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
      (writeShellApplication {
        name = "pipe-notify";
        text = ''
          NID=''$(${pkgs.libnotify}/bin/notify-send -p "...")
          MESSAGE=""
          while IFS= read -r -n 1 char || [[ -n "$char" ]]; do
            if [[ -z "$char" ]]; then
              MESSAGE="$MESSAGE\n"
            else
              MESSAGE="$MESSAGE$char"
            fi
            ${pkgs.libnotify}/bin/notify-send -r "$NID" "Shell" "$MESSAGE"
          done
        '';
      })
      # (writeShellApplication {
      #   name = "code";
      #   text = ''
      #     ifs=':' read -r -a array <<< "$3"
      #     foot --title="nvimunity" -- nvr --servername "/tmp/nvimunity" --remote-tab-silent "+''${array[1]}" "''${array[0]}"
      #   '';
      # })
      (writeShellApplication {
        name = "godot-nvim";
        text = ''
          FILE=/tmp/nvimgodot
          if test -e "$FILE"; then
            nvr --servername "$FILE" --remote-silent "+''$1" "''$2"
          fi
        '';
      })
      (writeShellApplication {
        name = "vpn-status";
        text = ''
          vpn=$(ifconfig | grep tun)

          if [[ $vpn ]]
          then
             echo "{\"class\": \"running\", \"text\": \"\", \"tooltip\": \"\"}"
             exit
          fi
        '';
      })
      (writeShellApplication {
        name = "dvt";
        text = ''
          nix flake init -t "github:the-nix-way/dev-templates#$1"
          direnv allow
        '';
      })
    ];
  };

  programs.godot4-mono-schnozzlecat = {
    enable = true;
    version = "4.2.2";
    commitHash = "315208a82eb0781f28e5348bdc59bf53b7796406";
    hash = "sha256-e9hosgfLxmRDTeocGLyHu+pzDi2TCrWmfrxUHFh1AgY=";
  };

  programs.ncspot = {
    enable = true;
    settings = {
      keybindings = {
        "Ctrl+f" = "focus search";
        "Ctrl+q" = "focus queue";
        "Ctrl+l" = "focus library";
      };
    };
  };

  services.pulseeffects = {
    enable = true;
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

  programs.mangohud = {
    enable = true;
    settings = {
      vulkan_driver = true;
      gpu_temp = true;
      gpu_mem_temp = true;
      vram = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_mhz = true;
      ram = true;
      io_read = true;
      io_write = true;
      gamemode = true;
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
      dragon-out = ''%${xdragon}/bin/xdragon -a -x $fx'';
      open = ''''${{${pkgs.ranger}/bin/rifle "$f"}}'';
      copy-path = ''&{{echo -n "$f" | wl-copy}}'';
      zip = ''
        %{{
          printf "Archive name >"
          read ARCHIVE
          if [ -n "$ARCHIVE" ]; then
              zip "$ARCHIVE" $fx
          fi
        }}
      '';
      unzip = ''
        %{{
          printf "Unarchive directory >"
          read ARCHIVE
          if [ -n "$ARCHIVE" ]; then
              mkdir -p "$ARCHIVE"
              unzip "$f"
          fi
        }}
      '';
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
      zz = "zip";
      zu = "unzip";
      "<c-f>" = "fzf_find";
      "<c-e>" = "fzf_exact";
      "<enter>" = "open";
    };
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
    command = "sleep 3 && foot -a foot-ncspot ncspot"
    animation = "fromBottom"
    margin = 50
    unfocus = "hide"

    [scratchpads.volume]
    command = "pavucontrol"
    animation = "fromRight"
  '';
  # home.file.".config/nvim/after/ftplugin/gdscript.lua".text = ''
  #   local port = os.getenv('GDScript_Port') or '6005'
  #   local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
  #   local pipe = '/path/to/godot.pipe' -- I use /tmp/godot.pipe

  #   vim.lsp.start({
  #     name = 'Godot',
  #     cmd = cmd,
  #     root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
  #     on_attach = function(client, bufnr)
  #       vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
  #     end
  #   })
  # '';

  programs.waybar = {
    enable = true;
    settings = import ./waybar-config.nix;
    style = import ./waybar-style.nix;
    package = master.waybar;
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
        min-width = 600;
        max-width = 600;
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

  programs.zellij = {
    enable = true;
    settings = {
      ui = {
        pane_frames = {
        };
      };
      on_force_close = "quit";
      "keybinds clear-defaults=true" = {
        "shared_except \"locked\"" = {
          "bind \"Alt n\"" = {NewPane = {};};
          "bind \"Alt t\"" = {NewTab = {};};
          "bind \"Alt m\"" = {ToggleFloatingPanes = {};};
          "bind \"Alt j\"" = {"MoveFocus \"Down\"" = {};};
          "bind \"Alt k\"" = {"MoveFocus \"Up\"" = {};};
          "bind \"Alt h\"" = {"MoveFocus \"Left\"" = {};};
          "bind \"Alt l\"" = {"MoveFocus \"Right\"" = {};};
          "bind \"Alt J\"" = {"Resize \"Increase Down\"" = {};};
          "bind \"Alt K\"" = {"Resize \"Increase Up\"" = {};};
          "bind \"Alt H\"" = {"Resize \"Increase Left\"" = {};};
          "bind \"Alt L\"" = {"Resize \"Increase Right\"" = {};};
          "bind \"Alt f\"" = {ToggleFocusFullscreen = {};};
          "bind \"Alt u\"" = {GoToPreviousTab = {};};
          "bind \"Alt i\"" = {GoToNextTab = {};};
          "bind \"Alt d\"" = {Detach = {};};
          "bind \"Alt r\"" = {
            "SwitchToMode \"RenameTab\"" = {};
            "TabNameInput 0" = {};
          };
          "bind \"Alt y\"" = {
            "LaunchOrFocusPlugin \"zellij:session-manager\"" = {
              floating = true;
              move_to_focused_tab = true;
            };
          };
        };
        renametab = {
          "bind \"Esc\"" = {"SwitchToMode \"Normal\"" = {};};
        };
      };
      theme = "catppuccin-mocha";
      themes = {
        catppuccin-mocha = {
          bg = "#585b70";
          fg = "#cdd6f4";
          red = "#f38ba8";
          green = "#a6e3a1";
          blue = "#89b4fa";
          yellow = "#f9e2af";
          magenta = "#f5c2e7";
          orange = "#fab387";
          cyan = "#89dceb";
          black = "#181825";
          white = "#cdd6f4";
        };
      };
    };
  };

  programs.zoxide = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      export OPENAI_API_KEY_DIR=${../secrets/keys/openapi.gpg}
      set -g fish_greeting
      bind \ce nvim
      if set -q ZELLIJ
      else
        zellij --layout compact
      end
    '';
    shellAliases = {
      gpt = "DEFAULT_MODEL=gpt-4-1106-preview OPENAI_API_KEY=$(gpg -q --decrypt $OPENAI_API_KEY_DIR) sgpt";
      pi-hdd = ''sshfs -o sftp_server="/usr/bin/sudo /usr/lib/openssh/sftp-server" -p 6969 pi@192.168.200.48:/mnt/hdd ~/Mounts/hdd'';
      pi-ssd = ''sshfs -o sftp_server="/usr/bin/sudo /usr/lib/openssh/sftp-server" -p 6969 pi@192.168.200.48:/mnt/ssd ~/Mounts/ssd'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/";
      home-rebuild = "home-manager switch --flake ~/.nixos/";
      ls = "eza -la";
      cat = "bat";
      # which-gpu = ''glxinfo| grep -E "OpenGL vendor|OpenGL renderer"'';
      # docker-stop-containers = "docker stop $(docker ps -a -q)";
      pi = "ssh pi@192.168.200.48 -p 6969";
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
