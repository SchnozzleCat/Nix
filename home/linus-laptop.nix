{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  colorScheme = {
    slug = "schnozzlecat";
    name = "schnozzlecat";
    colors = {
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

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config pkgs;})
    + ''
      monitor=eDP-1,1920x1080@144,0x0,1

      bind = $mainMod, 1, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers1.png}"
      bind = $mainMod, 2, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers2.png}"
      bind = $mainMod, 3, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers3.png}"
      bind = $mainMod, 4, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers4.png}"
      bind = $mainMod, 5, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers5.png}"
      bind = $mainMod, 6, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers6.png}"
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = eDP-1,${../secrets/wallpapers/flowers1.png}
    '';
}
