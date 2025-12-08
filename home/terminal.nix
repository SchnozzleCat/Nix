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

  home.packages = with pkgs; [
    (haskellPackages.ghcWithPackages (pkgs: with pkgs; [tidal]))
    supercollider-with-sc3-plugins
    lazygit
    lazysql
    jujutsu
    jjui
    lazydocker
    ctop
    nix-tree
    nix-index

    # Terminal
    p7zip
    eza
    fd
    television
    bat
    dust
    neofetch
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

    # inputs.csharp-language-server.packages.${pkgs.system}.csharp-language-server
    inputs.nix-software-center.packages.${system}.nix-software-center
  ];

  programs.yazi = {
    enable = true;
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
    settings = {
      line_break = {
        disabled = true;
      };
      # custom.jj = {
      #   command = ''
      #     jj log -r@ -n1 --ignore-working-copy --no-graph --color always  -T '
      #       separate(" ",
      #         bookmarks.map(|x| truncate_end(10, x.name(), "…")).join(" "),
      #         tags.map(|x| truncate_end(10, x.name(), "…")).join(" "),
      #         surround("\"", "\"", truncate_end(24, description.first_line(), "…")),
      #         if(conflict, "conflict"),
      #         if(divergent, "divergent"),
      #         if(hidden, "hidden"),
      #       )
      #     '
      #   '';
      #
      #   when = "jj root";
      #   symbol = "jj";
      # };
      # custom.jjstate = {
      #   when = "jj root";
      #   command = ''
      #     jj log -r@ -n1 --no-graph -T "" --stat | tail -n1 | sd "(\d+) files? changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)" ' ''\${1}m ''\${2}+ ''\${3}-' | sd " 0." ""
      #   '';
      # };
    };
  };

  programs.zellij = {
    enable = true;
  };
  home.file.".config/zellij/config.kdl".text = import ./zellij.nix {inherit pkgs inputs;};
  home.file.".config/zellij/layouts/default.kdl".text = import ./zellij-default.nix {
    inherit pkgs inputs;
  };

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
    '';
    shellAliases = {
      gpt = "DEFAULT_MODEL=gpt-4-1106-preview OPENAI_API_KEY=$(gpg -q --decrypt $OPENAI_API_KEY_DIR) sgpt";
      pi-hdd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/hdd ~/Mounts/hdd'';
      desktop-home = ''sshfs -o sftp_server="$(ssh linus@192.168.200.20 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.20:/home/linus ~/Mounts/desktop'';
      pi-ssd = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/ssd ~/Mounts/ssd'';
      pi-raid = ''sshfs -o sftp_server="/run/wrappers/bin/sudo $(ssh linus@192.168.200.66 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.66:/mnt/raid ~/Mounts/raid'';
      pi-build = ''NIX_SSHOPTS="-p 6969" nixos-rebuild switch --target-host linus@192.168.200.66 --flake ~/.nixos#schnozzlecat-server --sudo'';
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
