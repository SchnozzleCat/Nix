{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.nixvim = {
    enable = true;

    plugins = {
      lsp = {
        servers = {
          ltex = {
            enable = true;
          };
        };
      };
    };
  };
}
