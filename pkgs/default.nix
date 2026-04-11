# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  inky = pkgs.callPackage ./inky {};
  godot-custom = (pkgs.callPackage ./godot4-mono-schnozzlecat {}).godotPackages_4_6.godot-mono;
  sprite-illuminator = pkgs.callPackage ./sprite-illuminator {};
  zellij-pane-tracker = pkgs.callPackage ./zellij-pane-tracker {};
  linear-cli = pkgs.callPackage ./linear-cli {};
  zjctl = pkgs.callPackage ./zjctl {};
  meridian = pkgs.callPackage ./meridian {};
}
