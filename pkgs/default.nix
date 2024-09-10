# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  godot4-mono = pkgs.callPackage ./godot4-mono {};
  netcoredbg = pkgs.callPackage ./netcoredbg {};
  avante-nvim = (pkgs.callPackage ./avante-nvim {}).overrideAttrs {
    dependencies = with pkgs.vimPlugins; [
      dressing-nvim
      nui-nvim
      plenary-nvim
    ];
  };

  # godot4-mono-schnozzlecat = pkgs.callPackage ./godot4-mono-schnozzlecat {};
}
