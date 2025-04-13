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
    ./home.nix
  ];

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
  };

  wayland.windowManager.hyprland = {
    enable = true;
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER_SHIFT, f1, exec, foot
    bind = SUPER_SHIFT, f2, exec, godot4-mono-schnozzlecat
  '';
}
