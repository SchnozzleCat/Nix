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
    ./neovim.nix
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  home.packages = with pkgs; [
    lazygit
    ctop

    # Terminal
    eza
    bat
    du-dust
    neofetch
    cbonsai
    pipes
    pistol
    imv

    ripgrep
    fzf

    zip
    unzip

    wget

    cabextract

    neovim-remote
  ];

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

  home.file.".config/lf/icons".source = ./lf-icons.nix;
  home.file.".config/ranger/rifle".source = ./rifle.nix;

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

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
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
      pi-hdd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.48 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.48:/mnt/hdd ~/Mounts/hdd'';
      pi-ssd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.48 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.48:/mnt/ssd ~/Mounts/ssd'';
      pi-build = ''NIX_SSHOPTS="-p 6969" nixos-rebuild switch --target-host linus@192.168.200.48 --flake ~/.nixos#schnozzlecat-server --use-remote-sudo'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/";
      home-rebuild = "home-manager switch --flake ~/.nixos/";
      ls = "eza -la";
      cat = "bat";
      # which-gpu = ''glxinfo| grep -E "OpenGL vendor|OpenGL renderer"'';
      # docker-stop-containers = "docker stop $(docker ps -a -q)";
      pi = "ssh linus@192.168.200.48 -p 6969";
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
