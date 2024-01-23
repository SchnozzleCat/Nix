{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  master,
  nix-colors,
  ...
}: {
  imports = [
    ./home.nix
  ];

  home = {
    username = "test";
    homeDirectory = "/home/test";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      unityhub
    ];
  };
}
