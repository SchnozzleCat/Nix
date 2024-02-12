{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.godot4-mono-schnozzlecat;
  version = "SchnozzleCat-${lib.substring 0 10 cfg.commitHash}";
  pkg = pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {
    withVersion = cfg.version;
    withCommitHash = cfg.commitHash;
    withHash = cfg.hash;
  };
in {
  options.programs.godot4-mono-schnozzlecat = {
    enable = mkEnableOption (lib.mdDoc ''Godot4-mono SchnozzleCat'');
    version = mkOption {
      type = types.str;
      default = "4.2.2";
      description = "This must match the current Godot version.";
    };
    commitHash = mkOption {
      type = types.str;
    };
    hash = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkg
    ];
    home.file.".local/share/godot/export_templates/${cfg.version}.${version}.mono".source = "${pkg}/godot-export-templates";
    home.file."NuGet.Config".text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="${version}" value="${pkg}/${version}"/>
        </packageSources>
      </configuration>
    '';
  };
}
