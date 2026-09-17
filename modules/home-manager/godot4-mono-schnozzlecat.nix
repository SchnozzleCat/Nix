{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.godot4-mono-schnozzlecat;
  version = "4.7";
  suffix = "schnozzlecat-${lib.substring 0 4 cfg.commitHash}";
  godotPackages = (pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {}).godotPackages_4_7;
  pkg = godotPackages.godot-mono;
  export = godotPackages.godot-mono.export-template;
  export-debug = godotPackages.godot-mono.export-template-debug;

  # Windows (cross-compiled from Linux with MinGW-w64)
  winEditor = godotPackages.godot-mono-windows;
  winTemplate = winEditor.export-template;
  winTemplateDebug = winEditor.export-template-debug;
  winTemplateDir = "${winTemplate}/share/godot/export_templates/${version}.mono";
  winTemplateDebugDir = "${winTemplateDebug}/share/godot/export_templates/${version}.mono";
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
    installWindowsTemplates = mkOption {
      type = types.bool;
      default = true;
      description = "Install the Windows export templates (cross-compiled from Linux) alongside the Linux ones.";
    };
    installWindowsEditor = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Put the cross-compiled Windows editor in `~/.local/share/godot/windows-editor`
        so it can be copied/zipped to a Windows machine.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
    }
    (mkIf cfg.installWindowsTemplates {
      # Windows Desktop export templates, cross-compiled from Linux. These are
      # what `--export-release "Windows Desktop"` picks up.
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_release_x86_64.exe".source = "${winTemplateDir}/windows_release_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_release_x86_64_console.exe".source = "${winTemplateDir}/windows_release_x86_64_console.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_debug_x86_64.exe".source = "${winTemplateDebugDir}/windows_debug_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_debug_x86_64_console.exe".source = "${winTemplateDebugDir}/windows_debug_x86_64_console.exe";
      # Needed next to exported games when using GodotSteam on Windows.
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/steam_api64.dll".source = "${winTemplateDir}/steam_api64.dll";
    })
    (mkIf cfg.installWindowsEditor {
      home.file.".local/share/godot/windows-editor".source = winEditor;
    })
  ]);
}
