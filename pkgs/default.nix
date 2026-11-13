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

  # 2dog (Godot as a .NET library, https://2dog.dev) built against the fork:
  # a local NuGet feed with the 2dog tool/templates/engine/natives and the
  # fork's Godot.NET.Sdk. Wired up by programs.godot4-mono-schnozzlecat.twodog.
  twodog-custom = pkgs.callPackage ./2dog-schnozzlecat {
    steamworks-sdk = inputs.steamworks-sdk;
  };
  raspberrypifw-uart10 = pkgs.callPackage ./raspberrypifw-uart10 {};

  # bwrap-sandboxed pi coding agent (function, not a derivation -- call it:
  # `pkgs.makeJailedPi {extensionPackages = [...];}`). Shared implementation
  # with outputs.lib.makeJailedPi; see lib/jailed-pi.nix.
  makeJailedPi = pkgs.callPackage ../lib/jailed-pi.nix {jail-nix = inputs.jail-nix;};

  # Pi extension builder (function, not a derivation -- call it:
  # `pkgs.buildPiExtension {name = "owner/repo"; version = <rev>; ...}`).
  # lib/pi-extension.nix exports the function inside an attrset (mirror of
  # lib/jailed-pi.nix's attrset form); unwrap it here so callers get the
  # function directly. Declarative specs live in
  # home/config/pi-extensions.nix; shared implementation with
  # outputs.lib.buildPiExtension.
  buildPiExtension = (pkgs.callPackage ../lib/pi-extension.nix {}).buildPiExtension;
}
