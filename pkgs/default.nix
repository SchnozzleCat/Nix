# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
in {
  godot4-mono = pkgs.callPackage ./godot4-mono {};
  # godot4-mono-schnozzlecat = pkgs.callPackage ./godot4-mono-schnozzlecat {};
  roslyn-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "roslyn.nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "SchnozzleCat";
      repo = "roslyn.nvim";
      rev = "42a5661dc4403e0c414f8d5081fd65d17a6fd1bb";
      sha256 = "sha256-oG3hCszFhvR/rhP2Iz0Vtf8rim1byY/XsDdGYfNRX/w=";
    };
  };
  vesktop-patched = pkgs.callPackage ./vesktop-patched {};
  copilotchat-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "copilotchat-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "jellydn";
      repo = "CopilotChat.nvim";
      rev = "4b2e631dfd7e08507dd083a18480fe71a7bf8717";
      sha256 = "sha256-ft42fmJ4sJqo8P60JO41zTyTarNGL2anpNXrHpDFbbk=";
    };
  };
  tsc-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "tsc-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "dmmulroy";
      repo = "tsc.nvim";
      rev = "c37d7b3ed954e4db13814f0ed7aa2a83b2b7e9dd";
      sha256 = "sha256-ifJXtYCA04lt0z+JDWSesCPBn6OLpqnzJarK+wuo9m8=";
  tetris-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "tetris-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "alec-gibson";
      repo = "nvim-tetris";
      rev = "d17c99fb527ada98ffb0212ffc87ccda6fd4f7d9";
      sha256 = "sha256-+69Fq5aMMzg9nV05rZxlLTFwQmDyN5/5HmuL2SGu9xQ=";
    };
  };
  cellular-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "cellular-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "Eandrju";
      repo = "cellular-automaton.nvim";
      rev = "b7d056dab963b5d3f2c560d92937cb51db61cb5b";
      sha256 = "sha256-szbd6m7hH7NFI0UzjWF83xkpSJeUWCbn9c+O8F8S/Fg=";
    };
  };
}
