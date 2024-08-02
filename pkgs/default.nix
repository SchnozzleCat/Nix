# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  godot4-mono = pkgs.callPackage ./godot4-mono {};
  netcoredbg = pkgs.callPackage ./netcoredbg {};

  # godot4-mono-schnozzlecat = pkgs.callPackage ./godot4-mono-schnozzlecat {};
}
