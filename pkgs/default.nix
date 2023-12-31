# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
in {
  godot-4-mono = pkgs.callPackage ./godot4-mono {};
  roslyn-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "roslyn.nvim";
    version = "4.9.0-3.23604.10";
    src = pkgs.fetchFromGitHub {
      owner = "jmederosalvarado";
      repo = "roslyn.nvim";
      rev = "4.9.0-3.23604.10";
      sha256 = "sha256-LWe20cUtZKWJr9tWZgBP2/oZb9ipJTvKJFL5K+TZCrI=";
    };
    meta.homepage = "https://github.com/epwalsh/obsidian.nvim";
  };
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
