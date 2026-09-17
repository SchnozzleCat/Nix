# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, inputs, ...}: let
  godotPkgs = pkgs.callPackage ./godot4-mono-schnozzlecat {};
in {
  inky = pkgs.callPackage ./inky {};
  godot-custom = godotPkgs.godotPackages_4_7.godot-mono;
  godot-custom-windows-editor = godotPkgs.godotPackages_4_7.godot-mono-windows;
  godot-custom-windows-template = godotPkgs.godotPackages_4_7.godot-mono-windows-template;
  godot-custom-windows-template-debug = godotPkgs.godotPackages_4_7.godot-mono-windows-template-debug;
  sprite-illuminator = pkgs.callPackage ./sprite-illuminator {};
  linear-cli = pkgs.callPackage ./linear-cli {};
  meridian = pkgs.callPackage ./meridian {};
  agentic-af = pkgs.callPackage ./agentic-af {src = inputs.agentic-af;};
}
