{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.godot4-mono-schnozzlecat;
  version = "4.5.1";
  suffix = "schnozzlecat-${lib.substring 0 4 cfg.commitHash}";
  pkg = (pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {}).godotPackages_4_5.godot-mono;
  export = (pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {}).godotPackages_4_5.godot-mono.export-template;
  export-debug = (pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {}).godotPackages_4_5.godot-mono.export-template-debug;
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
    home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/linux_release.x86_64".source = "${export}/bin/godot-mono-template";
    home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/linux_debug.x86_64".source = "${export-debug}/bin/godot-mono-template";
    home.file."NuGet.Config".text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="${version}-${suffix}" value="${pkg}/libexec/${suffix}"/>
        </packageSources>
      </configuration>
    '';
  };
}
