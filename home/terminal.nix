{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  ...
}: let
  colors = config.colorScheme.palette;
in {
  imports = [
    ./neovim/neovim.nix
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  home.file.".config/jj/config.toml".source = ./jj.toml;

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "#FFA064"
            "bold"
          ];
          inactiveBorderColor = [
            "#739fd4"
          ];
          searchingActiveBorderColor = [
            "#FFA064"
            "bold"
          ];
          optionsTextColor = [
            "#5CCEFF"
          ];
          selectedLineBgColor = [
            "#33394a"
          ];
          cherryPickedCommitFgColor = [
            "#5CCEFF"
          ];
          cherryPickedCommitBgColor = [
            "#FFB3EC"
          ];
          markedBaseCommitFgColor = [
            "#5CCEFF"
          ];
          markedBaseCommitBgColor = [
            "#FFE77A"
          ];
          unstagedChangesColor = [
            "#F73F64"
          ];
          defaultFgColor = [
            "#E7EAEE"
          ];
        };
      };
    };
  };

  home.file.".config/opencode/config.json".text = import ./opencode-config.nix;

  programs.claude-code = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "opencode-wrapped";
      paths = [pkgs.opencode];

      buildInputs = [pkgs.makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/opencode \
          --set ANTHROPIC_API_KEY x \
          --set ANTHROPIC_BASE_URL http://127.0.0.1:3456
      '';
    };
  };

  home.packages = with pkgs; [
    (haskellPackages.ghcWithPackages (pkgs: with pkgs; [tidal]))
    supercollider-with-sc3-plugins
    lazysql
    jujutsu
    jjui
    lazydocker
    ctop
    nix-tree
    nix-index

    # Terminal
    fastfetch
    p7zip
    eza
    fd
    television
    bat
    dust
    cbonsai
    pipes
    pistol
    nix-output-monitor
    master.tattoy
    dive
    gemini-cli
    fabric-ai
    quarto

    ripgrep
    fzf

    zip
    unzip

    wget

    cabextract
  ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    enableFishIntegration = true;
    initLua = ./yazi.lua;
    plugins = {
      inherit (pkgs.yaziPlugins) smart-enter;
      inherit (pkgs.yaziPlugins) smart-filter;
      inherit (pkgs.yaziPlugins) smart-paste;
      inherit (pkgs.yaziPlugins) starship;
      inherit (pkgs.yaziPlugins) diff;
      inherit (pkgs.yaziPlugins) compress;
      inherit (pkgs.yaziPlugins) chmod;
      inherit (pkgs.yaziPlugins) bookmarks;
      inherit (pkgs.yaziPlugins) full-border;
      inherit (pkgs.yaziPlugins) git;
      inherit (pkgs.yaziPlugins) lazygit;
      inherit (pkgs.yaziPlugins) jjui;
      inherit (pkgs.yaziPlugins) lsar;
      inherit (pkgs.yaziPlugins) rich-preview;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["l"];
          run = "plugin smart-enter";
        }
        {
          on = ["L"];
          run = "plugin smart-enter detatch";
        }
        {
          on = ["<C-y>"];
          run = ''
            shell '${pkgs.dragon-drop}/bin/xdragon -a -x -T "$@"'
          '';
        }
        {
          on = ["c" "y"];
          run = ''
            shell '${pkgs.dragon-drop}/bin/xdragon -a -x -T "$@"'
          '';
        }
        {
          on = ["<C-g>"];
          run = "shell 'lazygit' --confirm --block";
        }
        {
          on = ["T"];
          run = "tasks_show";
        }
        {
          on = ["F"];
          run = "plugin --sync max-preview";
        }

        {
          on = ["C"];
          run = "plugin chmod";
        }
        {
          on = ["W"];
          run = "plugin diff";
        }
        {
          on = ["c" "a"];
          run = "plugin compress";
        }
        {
          on = ["g" "n"];
          run = "cd ~/.nixos";
        }
        {
          on = ["g" "l"];
          run = "cd ~/.local/share";
        }
        {
          on = ["g" "s"];
          run = "cd ~/.local/share/Steam/steamapps/common";
        }
      ];
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "teide-dark";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      vim_keys = true;
    };
    themes = {
      teide-dark = ''
        # Theme: teide_dark
        # By: Folke Lemaitre & Sergio Hernandez

        theme[main_bg]="#1D2228"
        theme[main_fg]="#E7EAEE"

        # Title color for boxes
        theme[title]="#E7EAEE"

        # Highlight color for keyboard shortcuts
        theme[hi_fg]="#FFA064"

        # Selected item in processes box
        theme[selected_bg]="#2C313A"
        theme[selected_fg]="#0AE7FF"

        # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
        theme[proc_misc]="#0AE7FF"

        # Cpu box outline color
        theme[cpu_box]="#739fd4"

        # Memory/disks box outline color
        theme[mem_box]="#739fd4"

        # Net up/down box outline color
        theme[net_box]="#739fd4"

        # Processes box outline color
        theme[proc_box]="#739fd4"

        # Box divider line and small boxes line color
        theme[div_line]="#739fd4"

        # Temperature graph colors
        theme[temp_start]="#38FFA5"
        theme[temp_mid]="#FFE77A"
        theme[temp_end]="#F97791"

        # CPU graph colors
        theme[cpu_start]="#38FFA5"
        theme[cpu_mid]="#FFE77A"
        theme[cpu_end]="#F97791"

        # Mem/Disk free meter
        theme[free_start]="#38FFA5"
        theme[free_mid]="#FFE77A"
        theme[free_end]="#F97791"

        # Mem/Disk cached meter
        theme[cached_start]="#38FFA5"
        theme[cached_mid]="#FFE77A"
        theme[cached_end]="#F97791"

        # Mem/Disk available meter
        theme[available_start]="#38FFA5"
        theme[available_mid]="#FFE77A"
        theme[available_end]="#F97791"

        # Mem/Disk used meter
        theme[used_start]="#38FFA5"
        theme[used_mid]="#FFE77A"
        theme[used_end]="#F97791"

        # Download graph colors
        theme[download_start]="#38FFA5"
        theme[download_mid]="#FFE77A"
        theme[download_end]="#F97791"

        # Upload graph colors
        theme[upload_start]="#38FFA5"
        theme[upload_mid]="#FFE77A"
        theme[upload_end]="#F97791"
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      line_break = {
        disabled = true;
      };
      custom.jj = {
        description = "The current jj status";
        when = "jj --ignore-working-copy root";
        symbol = "🥋 ";
        command = ''
          jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
            separate(" ",
              change_id.shortest(4),
              bookmarks,
              "|",
              concat(
                if(conflict, "💥"),
                if(divergent, "🚧"),
                if(hidden, "👻"),
                if(immutable, "🔒"),
              ),
              raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
              raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                truncate_end(29, description.first_line(), "…"),
                "(no description set)",
              ) ++ raw_escape_sequence("\x1b[0m"),
            )
          '
        '';
      };

      git_status.disabled = true;
      custom.git_status = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_status";
        style = "";
        description = "Only show git_status if we're not in a jj repo";
      };

      git_commit.disabled = true;
      custom.git_commit = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_commit";
        style = "";
        description = "Only show git_commit if we're not in a jj repo";
      };

      git_metrics.disabled = true;
      custom.git_metrics = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_metrics";
        description = "Only show git_metrics if we're not in a jj repo";
        style = "";
      };

      git_branch.disabled = true;
      custom.git_branch = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_branch";
        description = "Only show git_branch if we're not in a jj repo";
        style = "";
      };
    };
  };

  programs.zellij = {
    enable = true;
  };
  home.file.".config/zellij/config.kdl".text = import ./zellij.nix {inherit pkgs inputs;};
  home.file.".config/zellij/layouts/default.kdl".text = import ./zellij-default.nix {
    inherit pkgs inputs;
  };
  home.file.".config/zellij/plugins/zellij-pane-tracker.wasm".source = "${pkgs.zellij-pane-tracker}/bin/zellij-pane-tracker.wasm";
  home.file.".config/zellij/plugins/zrpc.wasm".source = "${pkgs.zjctl}/bin/zrpc.wasm";

  programs.zoxide = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      bind -s \ce "zellij_tab_name_update neovim && neovim && zellij_tab_name_update shell"
      bind -s \cj "zellij_tab_name_update lazygit && jjui && zellij_tab_name_update shell"
      bind -s \cg "zellij_tab_name_update lazygit && lazygit && zellij_tab_name_update shell"
      bind -s \cb "zellij_tab_name_update television && z (z ~/Repositories && tv git-repos) && zellij_tab_name_update shell && commandline -f repaint"
      function yy
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
      zellij action rename-tab shell
      function zellij_tab_name_update --on-event fish_preexec
          if set -q ZELLIJ
              set title (string split ' ' $argv)[1]
              command nohup zellij action rename-tab $title >/dev/null 2>&1
          end
      end
      function zellij_tab_name_exit --on-event fish_postexec
          if set -q ZELLIJ
              command nohup zellij action rename-tab shell >/dev/null 2>&1
          end
      end
      clear

      # Teide Color Palette
      set -l foreground E7EAEE
      set -l selection 33394a
      set -l comment 586172
      set -l red F97791
      set -l orange FFA064
      set -l yellow FFE77A
      set -l green 38FFA5
      set -l purple F7D96C
      set -l cyan 0AE7FF
      set -l pink FFB3EC

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_option $pink
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
    shellAliases = {
      gpt = "DEFAULT_MODEL=gpt-4-1106-preview OPENAI_API_KEY=$(gpg -q --decrypt $OPENAI_API_KEY_DIR) sgpt";
      pi-hdd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/hdd ~/Mounts/hdd'';
      desktop-home = ''sshfs -o sftp_server="$(ssh linus@192.168.200.20 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.20:/home/linus ~/Mounts/desktop'';
      pi-ssd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/ssd ~/Mounts/ssd'';
      pi-raid = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/raid ~/Mounts/raid'';
      pi-build = ''NIX_SSHOPTS="-p 6969" nixos-rebuild switch --target-host linus@192.168.200.66 --flake ~/.nixos#rpi5 --sudo'';
      pi-laptop = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.60 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.60:/home/linus ~/Mounts/laptop'';
      neovim = ''nvim'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/ &| ${pkgs.nix-output-monitor}/bin/nom";
      home-rebuild = "home-manager switch --flake ~/.nixos/ &| ${pkgs.nix-output-monitor}/bin/nom";
      ls = "eza -la";
      cat = "bat";
      pi = "ssh linus@192.168.200.66 -p 6969";
      rm = "rm -I";
      mv = "mv -i";
      untar = "tar -xvf";
      zz = "zellij";
      cd = "z";
    };
  };
}
