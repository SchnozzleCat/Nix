{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixvim = {
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
