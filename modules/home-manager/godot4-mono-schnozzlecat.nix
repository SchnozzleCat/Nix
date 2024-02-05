{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.godot4-mono-schnozzlecat;
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
      (pkgs.godot4-mono-schnozzlecat.override {
        withVersion = cfg.version;
        withCommitHash = cfg.commitHash;
        withHash = cfg.hash;
      })
    ];
    home.file.".local/share/godot/export_templates/${cfg.version}.SchnozzleCat-${cfg.commitHash}.mono".source = "${pkgs.godot4-mono-schnozzlecat}/godot-export-templates";
    home.file."NuGet.Config".text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="SchnozzleCat-${cfg.commitHash}" value="${pkgs.godot4-mono-schnozzlecat}/schnozzlecat/"/>
        </packageSources>
      </configuration>
    '';
  };
}
