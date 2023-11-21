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
  '';

  home.file.".config/hypr/hyprpaper.conf".text = hyprpaperConf + ''
  '';
}
