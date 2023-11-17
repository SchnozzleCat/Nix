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
        texLivePackage = pkgs.texlive.combined.scheme-full;
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
