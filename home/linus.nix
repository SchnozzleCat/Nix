{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  ...
}:
let
colors = config.colorScheme.colors;
in
{
  imports = [
    ./home.nix
    ./neovim.nix
  ];

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    packages = with pkgs; [
      # OS
      fuzzel
      fnott
      waybar
      jetbrains-mono

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
      gammastep
      ripgrep
      fzf

      # Terminal
      foot
      fish
      starship
      zoxide
      eza
      bat
      neovim
      xdragon
      btop
      zellij
      du-dust
      ncspot
      neofetch
      cbonsai
      pipes
      lf

      # Files
      zathura

      # Games
      steam
      steam-run
      lutris

      # Misc
      obsidian
      helvum
    ];
  };

  programs.git = {
      enable = true;
      userName = "SchnozzleCat";
      userEmail = "git@schnozzlecat.com";
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware="no";
        width=35;
        font="JetBrainsMono Nerd Font:size=16";
        icon-theme="candy-icons-master";
        line-height=25;
        fields="name,generic,comment,categories,filename,keywords";
        terminal="foot -e";
        prompt="❯   ";
        layer="overlay";
      };
      colors = {
        background="${colors.base00}ee";
        selection="${colors.base04}fa";
        border="${colors.base08}ff";
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

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
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
