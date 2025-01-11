{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  master,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  colorScheme = {
    name = "schnozzlecat";
    palette = {
      base00 = "#1F1F28";
      base01 = "#2a273f";
      base02 = "#393552";
      base03 = "#6e6a86";
      base04 = "#908caa";
      base05 = "#e0def4";
      base06 = "#e0def4";
      base07 = "#56526e";
      base08 = "#eb6f92";
      base09 = "#f6c177";
      base0A = "#ea9a97";
      base0B = "#3e8fb0";
      base0C = "#9ccfd8";
      base0D = "#c4a7e7";
      base0E = "#f6c177";
      base0F = "#56526e";
    };
  };

  home.packages = with pkgs; [
    wireguard-tools
    parsec-bin
  ];

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config pkgs;})
    + ''
      monitor=eDP-1,2880x1800@120,0x0,auto
      monitor=HDMI-A-1,1920x1080@60,1920x0,1
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = eDP-1,${../secrets/wallpapers/abstract1.jpg}
      wallpaper = HDMI-A-1,${../secrets/wallpapers/abstract1.jpg}
    '';
}
