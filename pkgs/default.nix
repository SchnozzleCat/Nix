# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
in {
  godot-4-mono = pkgs.callPackage ./godot4-mono {};
  obsidian-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "obsidian-nvim";
    version = "v2.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "epwalsh";
      repo = "obsidian.nvim";
      rev = "v2.3.1";
      sha256 = "sha256-g9GFq5FMaCcJ6HbnhRgCmioLvaJ4SK6jSioDi5lXeP4=";
    };
    meta.homepage = "https://github.com/epwalsh/obsidian.nvim";
  };
}
