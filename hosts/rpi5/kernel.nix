# Cross-compile the Raspberry Pi vendor kernel on x86_64 instead of building
# it under qemu-user emulation (binfmt). The kernel isn't in the binary cache
# (nixos-hardware callPackages it), so it's built locally on every bump, and
# emulated that takes hours; a native x86 cross compiler takes minutes.
# The rest of the system stays native aarch64 and comes from the cache.
#
# Same source/config as nixos-hardware's raspberry-pi-5 module (which sets
# this with mkDefault); only the build platform differs.
#
# Consequences:
# - Building the system requires an x86_64-linux builder (the desktop, as
#   with `pi-build`); the Pi can't rebuild its own kernel anymore.
# - Out-of-tree modules must come from this same package set
#   (config.boot.kernelPackages.<name>), never from native pkgs.
{
  inputs,
  ...
}: let
  pkgsCross = import inputs.nixpkgs {
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in {
  boot.kernelPackages = pkgsCross.linuxPackagesFor (
    pkgsCross.callPackage "${inputs.nixos-hardware}/raspberry-pi/common/kernel.nix" {
      rpiVersion = 5;
    }
  );
}
