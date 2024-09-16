# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  avante-nvim = (pkgs.callPackage ./avante-nvim {}).overrideAttrs {
    dependencies = with pkgs.vimPlugins; [
      dressing-nvim
      nui-nvim
      plenary-nvim
    ];
  };
}
