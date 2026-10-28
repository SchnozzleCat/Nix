# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, inputs, ...}: let
  # steamworks-sdk is the Steamworks SDK zip flake input (see flake.nix); a
  # store path, passed down to pkgs/godot4-mono-schnozzlecat.
  godotPkgs = pkgs.callPackage ./godot4-mono-schnozzlecat {
    steamworks-sdk = inputs.steamworks-sdk;
  };
in {
  godot-custom = godotPkgs.godotPackages_4_7.godot-mono;
  godot-custom-windows-editor = godotPkgs.godotPackages_4_7.godot-mono-windows;
  godot-custom-windows-template = godotPkgs.godotPackages_4_7.godot-mono-windows-template;
  godot-custom-windows-template-debug = godotPkgs.godotPackages_4_7.godot-mono-windows-template-debug;
  agentic-af = pkgs.callPackage ./agentic-af {src = inputs.agentic-af;};
  raspberrypifw-uart10 = pkgs.callPackage ./raspberrypifw-uart10 {};

  # bwrap-sandboxed pi coding agent (function, not a derivation -- call it:
  # `pkgs.makeJailedPi {extensionPackages = [...];}`). Shared implementation
  # with outputs.lib.makeJailedPi; see lib/jailed-pi.nix.
  makeJailedPi = pkgs.callPackage ../lib/jailed-pi.nix {jail-nix = inputs.jail-nix;};
}
