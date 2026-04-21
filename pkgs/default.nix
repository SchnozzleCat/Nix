# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  pi-sandbox = import ./pi-sandbox-image.nix {inherit pkgs;};
in {
  inky = pkgs.callPackage ./inky {};
  godot-custom = (pkgs.callPackage ./godot4-mono-schnozzlecat {}).godotPackages_4_6.godot-mono;
  sprite-illuminator = pkgs.callPackage ./sprite-illuminator {};
  linear-cli = pkgs.callPackage ./linear-cli {};
  meridian = pkgs.callPackage ./meridian {};
  pi-sandbox-image = pi-sandbox.image;
  pi-coding-agent-pin = pi-sandbox.piPkg;
}