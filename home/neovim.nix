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
        installTexLive = true;
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
