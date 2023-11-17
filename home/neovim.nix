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
      vimtex = {
        enable = true;
        viewMethod = "zathura";
      };
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
