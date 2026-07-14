# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, inputs, ...}: {
  inky = pkgs.callPackage ./inky {};
  godot-custom = (pkgs.callPackage ./godot4-mono-schnozzlecat {}).godotPackages_4_7.godot-mono;
  sprite-illuminator = pkgs.callPackage ./sprite-illuminator {};
  linear-cli = pkgs.callPackage ./linear-cli {};
  meridian = pkgs.callPackage ./meridian {};
  agentic-af = pkgs.callPackage ./agentic-af {src = inputs.agentic-af;};
}
