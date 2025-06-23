{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
  };

  programs.godot4-mono-schnozzlecat = {
    enable = true;
    version = "4.4";
    commitHash = "4c575e3f3801bfc615ebf9c923b587f1548f5dd6";
    hash = "sha256-t0HuAwuylNIHFv+zZzWWKK9axno9wDpRbIhtgFaVJ9Q=";
  };

  wayland.windowManager.hyprland = {
    enable = true;
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER_SHIFT, f1, exec, foot
    bind = SUPER_SHIFT, f2, exec, godot4-mono-schnozzlecat
  '';

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
