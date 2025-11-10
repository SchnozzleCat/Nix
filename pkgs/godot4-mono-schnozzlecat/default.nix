# TODO:
# - combine binary and source tests
# - filter builtInputs by builtin_ flags
{
  callPackage,
  lib,
  nix-update-script,
  fetchzip,
}: let
  mkGodotPackages = versionPrefix: let
    attrs = (import (./. + "/${versionPrefix}/default.nix")) {inherit lib;};
    updateScript = [
      ./update.sh
      versionPrefix
      (builtins.unsafeGetAttrPos "version" attrs).file
    ];
  in
    lib.recurseIntoAttrs rec {
      godot = callPackage ./common.nix {
        inherit updateScript;
        inherit
          (attrs)
          version
          rev
          hash
          ;
        inherit
          (attrs.default)
          exportTemplatesHash
          ;
      };

      godot-mono = godot.override {
        withMono = true;
        inherit
          (attrs.mono)
          exportTemplatesHash
          nugetDeps
          ;
      };

      export-template = godot.export-template;
      export-template-mono = godot-mono.export-template;

      export-templates-bin = godot.export-templates-bin;
      export-templates-mono-bin = godot-mono.export-templates-bin;
    };
in {
  godotPackages_4_5 = mkGodotPackages "4.5";
}
