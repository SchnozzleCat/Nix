# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  godot-4-mono = pkgs.callPackage ./godot4-mono {};
}
