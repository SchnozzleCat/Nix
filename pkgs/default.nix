# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
in {
  godot4-mono = pkgs.callPackage ./godot4-mono {};
  # godot4-mono-schnozzlecat = pkgs.callPackage ./godot4-mono-schnozzlecat {};
  roslyn-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "roslyn.nvim";
    version = "4.9.0-3.23604.10";
    src = pkgs.fetchFromGitHub {
      owner = "jmederosalvarado";
      repo = "roslyn.nvim";
      rev = "4.9.0-3.23604.10";
      sha256 = "sha256-LWe20cUtZKWJr9tWZgBP2/oZb9ipJTvKJFL5K+TZCrI=";
    };
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
  };
  copilotchat-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "copilotchat-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "jellydn";
      repo = "CopilotChat.nvim";
      rev = "90fe665555e529e3bf653ab59cb5cd72ba6174a0";
      sha256 = "sha256-n+iK97uSOYdlQZSZV3JJHBWKHi7UPPKpKUZm4eUDIGs=";
    };
  };
}
