{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./home.nix
    ./neovim.nix
  ];

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    packages = with pkgs; [
      fuzzel
      jetbrains-mono
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
        background="1e1d2dee";
        selection="3d4474fa";
        border="94E2D5ff";
      };
      border = {
        radius = 1;
      };
      dmenu = {
        exit-immediately-if-empty = "yes";
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
