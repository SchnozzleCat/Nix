# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./home.nix
    ./terminal.nix
  ];

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
  };
}
