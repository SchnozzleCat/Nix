{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
hyprConf = import ./hyprland.nix;
in
{
  imports = [
    ./linus.nix
  ];

  wayland.windowManager.hyprland.extraConfig = hyprConf + ''

  '';
}
