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
    globals = {
      vimtex_view_method = "zathura";
    };
    plugins = {
      vimtex = {
        enable = true;
        installTexLive = true;
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
