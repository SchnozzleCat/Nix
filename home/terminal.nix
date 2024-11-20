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

    ripgrep
    fzf

    zip
    unzip

    wget

    cabextract

    neovim-remote
  ];

  programs.yazi = {
    enable = true;
    package = pkgs.master.yazi;
    enableFishIntegration = true;
    initLua = ./yazi/init.lua;
  };
  home.file.".config/yazi/flavors".source = ./yazi/flavors;
  home.file.".config/yazi/plugins".source = ./yazi/plugins;
  home.file.".config/yazi/theme.toml".source = ./yazi/theme.toml;
  home.file.".config/yazi/keymap.toml".text = import ./yazi/keymap.nix {inherit pkgs;};
  home.file.".config/yazi/yazi.toml".source = ./yazi/yazi.toml;

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
      pane_frames = false;
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
      set -g fish_greeting
      bind -s \ce neovim
      function yy
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
      clear
    '';
    shellAliases = {
      gpt = "DEFAULT_MODEL=gpt-4-1106-preview OPENAI_API_KEY=$(gpg -q --decrypt $OPENAI_API_KEY_DIR) sgpt";
      pi-hdd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.48 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.48:/mnt/hdd ~/Mounts/hdd'';
      pi-ssd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.48 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.48:/mnt/ssd ~/Mounts/ssd'';
      pi-build = ''NIX_SSHOPTS="-p 6969" nixos-rebuild switch --target-host linus@192.168.200.48 --flake ~/.nixos#schnozzlecat-server --use-remote-sudo'';
      neovim = ''ANTHROPIC_API_KEY=(cat /home/linus/.nixos/secrets/keys/anthropic.key) nvim'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/ &| ${pkgs.nix-output-monitor}/bin/nom";
      home-rebuild = "home-manager switch --flake ~/.nixos/ &| ${pkgs.nix-output-monitor}/bin/nom";
      ls = "eza -la";
      cat = "bat";
      pi = "ssh linus@192.168.200.48 -p 6969";
      rm = "rm -I";
      mv = "mv -i";
      untar = "tar -xvf";
      zz = "zellij -l compact";
      cd = "z";
    };
  };
}
