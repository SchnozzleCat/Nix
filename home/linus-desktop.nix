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

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config;})
    + ''
      monitor=DP-1,3440x1440@144,0x0,1
      monitor=DP-2,1920x1080@60,0x-1080,1
      monitor=DP-3,1920x1080@60,1920x-1080,1
      monitor=HDMI-A-1,1920x1080@60,3440x-1080,1

      workspace=DP-1,1
      workspace=DP-1,2
      workspace=DP-1,3
      workspace=DP-2,4
      workspace=DP-3,5

      bind = $mainMod, 1, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers1.png}"
      bind = $mainMod, 2, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers5.png}"
      bind = $mainMod, 3, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers6.png}"
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = DP-1,${../secrets/wallpapers/flowers1.png}
      wallpaper = DP-2,${../secrets/wallpapers/flowers2.png}
      wallpaper = DP-3,${../secrets/wallpapers/flowers3.png}
      wallpaper = HDMI-A-1,${../secrets/wallpapers/flowers4.png}
    '';
}
