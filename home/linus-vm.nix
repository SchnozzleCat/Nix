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
    version = "4.4.1";
    commitHash = "4093498c254cf24aad3afddf1b4b29423744e6ff";
    hash = "sha256-DyWVGLmK5JbhKYUdHIBHyDMZEjZ/N7Ooyfpir2+kAEk=";
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
