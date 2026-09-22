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

  # The single editor. With `withTracy` it's built with the Tracy profiler
  # enabled; otherwise it's the plain build.
  # https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
  tracyOverrides = {
    withTracy = true;
    withTracyTrackMemory = cfg.withTracyTrackMemory;
    withTracyExportCapi = cfg.withTracyExportCapi;
  };
  pkg =
    if cfg.withTracy
    then godotPackages.godot-mono.override tracyOverrides
    else godotPackages.godot-mono;

  # Two export template sets:
  #
  #   - The editor's *own* template directory
  #     (~/.local/share/godot/export_templates/${version}.${suffix}.mono)
  #     holds the profiler-free set, so a plain `--export-release` always
  #     ships a clean build. F5 runs don't use templates at all — the editor
  #     spawns its own (Tracy-enabled) binary — so profiling from the editor
  #     is unaffected by which set sits here.
  #
  #   - The Tracy set lives in a sibling directory (…-tracy) that no editor
  #     picks up automatically. To profile an exported game, add an export
  #     preset whose `custom_template/release` and `custom_template/debug`
  #     options point at the binaries below, then run that export with the
  #     Tracy GUI connected.
  tracyExport = pkg.export-template;
  tracyExportDebug = pkg.export-template-debug;
  tracyTemplateDir = "${version}.${suffix}-tracy.mono";

  cleanExport = godotPackages.godot-mono.export-template;
  cleanExportDebug = godotPackages.godot-mono.export-template-debug;

  # Windows (cross-compiled from Linux with MinGW-w64). Two builds: the tracy
  # one (also the one `installWindowsEditor` ships) and a clean one.
  winEditor =
    if cfg.withTracy
    then godotPackages.godot-mono-windows.override tracyOverrides
    else godotPackages.godot-mono-windows;
  winCleanEditor = godotPackages.godot-mono-windows;
  winCleanTemplateDir = "${winCleanEditor.export-template}/share/godot/export_templates/${version}.mono";
  winCleanTemplateDebugDir = "${winCleanEditor.export-template-debug}/share/godot/export_templates/${version}.mono";
  winTracyTemplateDir = "${winEditor.export-template}/share/godot/export_templates/${version}.mono";
  winTracyTemplateDebugDir = "${winEditor.export-template-debug}/share/godot/export_templates/${version}.mono";

  nugetConfig = ''
    <?xml version="1.0" encoding="utf-8"?>
    <configuration>
      <packageSources>
        <add key="${version}-${suffix}" value="${pkg}/libexec/${suffix}"/>
      </packageSources>
    </configuration>
  '';
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
    withTracy = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Build the editor with the built-in Tracy profiler (F5 runs spawn the
        editor's own binary, so they are profilable), and install an extra
        Tracy export template set under
        `export_templates/${version}.${suffix}-tracy.mono` for profiling
        exported games via a preset's `custom_template` options. The default
        template set stays profiler-free so plain exports ship clean builds.
        https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
      '';
    };
    withTracyTrackMemory = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Track every engine allocation/free with Tracy
        (GODOT_PROFILER_TRACK_MEMORY). Moderate overhead while the profiler
        is connected; enable this for memory profiling sessions. C#/.NET GC
        allocations are not covered by this (use dotnet-gcdump for those).
      '';
    };
    withTracyExportCapi = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Export Tracy's C API (`___tracy_*` symbols) from the built binaries,
        so C# code running inside a Godot game can P/Invoke into the engine's
        Tracy session instead of creating its own profiler client.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        pkg
      ];
      # Profiler-free templates in the editor's default directory: a plain
      # `--export-release` always produces a clean, shippable build. (F5 runs
      # don't use templates — the editor spawns its own Tracy-enabled
      # binary.)
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/linux_release.x86_64".source = "${cleanExport}/bin/godot-mono-template";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/linux_debug.x86_64".source = "${cleanExportDebug}/bin/godot-mono-template";
      home.file."NuGet.Config".text = nugetConfig;
    }
    (mkIf cfg.withTracy {
      # Tracy templates in a sibling directory of the editor's default one;
      # nothing resolves this automatically. Reference it from a "Profile"
      # export preset via e.g. (Linux):
      #   custom_template/release="~/.local/share/godot/export_templates/${version}.${suffix}-tracy.mono/linux_release.x86_64"
      #   custom_template/debug="~/.local/share/godot/export_templates/${version}.${suffix}-tracy.mono/linux_debug.x86_64"
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/linux_release.x86_64".source = "${tracyExport}/bin/godot-mono-template";
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/linux_debug.x86_64".source = "${tracyExportDebug}/bin/godot-mono-template";
    })
    (mkIf cfg.installWindowsTemplates {
      # Windows Desktop export templates, cross-compiled from Linux. These are
      # what `--export-release "Windows Desktop"` picks up (the profiler-free
      # set).
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_release_x86_64.exe".source = "${winCleanTemplateDir}/windows_release_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_release_x86_64_console.exe".source = "${winCleanTemplateDir}/windows_release_x86_64_console.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_debug_x86_64.exe".source = "${winCleanTemplateDebugDir}/windows_debug_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/windows_debug_x86_64_console.exe".source = "${winCleanTemplateDebugDir}/windows_debug_x86_64_console.exe";
      # Needed next to exported games when using GodotSteam on Windows.
      home.file.".local/share/godot/export_templates/${version}.${suffix}.mono/steam_api64.dll".source = "${winCleanTemplateDir}/steam_api64.dll";
    })
    (mkIf (cfg.installWindowsTemplates && cfg.withTracy) {
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/windows_release_x86_64.exe".source = "${winTracyTemplateDir}/windows_release_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/windows_release_x86_64_console.exe".source = "${winTracyTemplateDir}/windows_release_x86_64_console.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/windows_debug_x86_64.exe".source = "${winTracyTemplateDebugDir}/windows_debug_x86_64.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/windows_debug_x86_64_console.exe".source = "${winTracyTemplateDebugDir}/windows_debug_x86_64_console.exe";
      home.file.".local/share/godot/export_templates/${version}.${suffix}-tracy.mono/steam_api64.dll".source = "${winTracyTemplateDir}/steam_api64.dll";
    })
    (mkIf cfg.installWindowsEditor {
      home.file.".local/share/godot/windows-editor".source = winEditor;
    })
  ]);
}
