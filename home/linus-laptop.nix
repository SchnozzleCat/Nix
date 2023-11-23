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
