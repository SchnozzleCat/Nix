# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
in {
  godot4-mono = pkgs.callPackage ./godot4-mono {};
  # godot4-mono-schnozzlecat = pkgs.callPackage ./godot4-mono-schnozzlecat {};
  roslyn-ls = pkgs.callPackage ./roslyn-ls {};
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
}
