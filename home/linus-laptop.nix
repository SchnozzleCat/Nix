{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
hyprlandConf = import ./hyprland.nix;
hyprpaperConf = import ./hyprpaper.nix;
in
{
  imports = [
    ./linus.nix
  ];

  wayland.windowManager.hyprland.extraConfig = hyprlandConf + ''
bind = $mainMod, 1, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers1.png}"
bind = $mainMod, 2, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers2.png}"
bind = $mainMod, 3, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers3.png}"
bind = $mainMod, 4, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers4.png}"
bind = $mainMod, 5, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers5.png}"
bind = $mainMod, 6, exec, hyprctl hyprpaper wallpaper "eDP-1,${../secrets/wallpapers/flowers6.png}"
  '';

  home.file.".config/hypr/hyprpaper.conf".text = hyprpaperConf + ''
wallpaper = eDP-1,${../secrets/wallpapers/flowers1.png}
  '';
}
