# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  inky = pkgs.callPackage ./inky {};
  goose-cli = pkgs.callPackage ./goose-cli {};
}
