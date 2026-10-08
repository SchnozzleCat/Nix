{
  pkgs,
  inputs,
}: let
  ue4-27 = pkgs.callPackage ./ue4-27.nix {};
  ue5-8 = pkgs.callPackage ./ue5-8.nix {};
in {
  inherit ue4-27 ue5-8;
  default = ue4-27;
}
