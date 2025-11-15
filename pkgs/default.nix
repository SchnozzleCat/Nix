# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, ... }:
{
  inky = pkgs.callPackage ./inky { };
  godot-custom = (pkgs.callPackage ./godot4-mono-schnozzlecat { }).godotPackages_4_5.godot-mono;
}
