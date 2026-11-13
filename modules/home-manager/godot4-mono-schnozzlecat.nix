{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.programs.godot4-mono-schnozzlecat;
  # Version prefix — must match a directory in pkgs/godot4-mono-schnozzlecat/.
  version = cfg.version;
  # Optional source overrides: set `rev` (plus the matching `hash`) to build a
  # different commit than the one pinned in the version dir. Nulls are
  # filtered out so the version dir's pins apply by default.
  sourceOverrides = lib.filterAttrs (_: v: v != null) {
    inherit (cfg) rev hash;
  };
  godotPackages =
    (pkgs.callPackage ../../pkgs/godot4-mono-schnozzlecat {
      steamworks-sdk = inputs.steamworks-sdk;
    })
    .mkGodotPackages
    version
    sourceOverrides;
  # Effective source rev (the override if set, otherwise the version dir's pin).
  rev = godotPackages.godot.rev;
  suffix = "schnozzlecat-${lib.substring 0 4 rev}";

  # Forward all profiler options into the package.
  # https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
  tracyOverrides = {
    inherit (cfg) withTracy withTracyTrackMemory withTracyExportCapi;
  };
  pkg = godotPackages.godot-mono.override tracyOverrides;

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

  # 2dog (Godot as a .NET library, https://2dog.dev) built against the same
  # fork rev + Tracy flags: a local NuGet feed (pkgs/2dog-schnozzlecat).
  twodogCfg = cfg.twodog;
  twodogPkg = pkgs.callPackage ../../pkgs/2dog-schnozzlecat {
    steamworks-sdk = inputs.steamworks-sdk;
    forkRev = cfg.rev;
    forkHash = cfg.hash;
    inherit (cfg) withTracy withTracyTrackMemory withTracyExportCapi;
    inherit (twodogCfg) withWindows withWeb withWebThreads withWebGpu;
  };
  twodogFeed = "${twodogPkg}/share/2dog-feed";

  # With 2dog enabled, package source mapping makes the 2dog/Godot packages
  # resolve ONLY from the local feeds (never from nuget.org's identically
  # named public packages), per https://2dog.dev/godot-forks.html. All
  # other packages keep coming from nuget.org.
  nugetConfig =
    if !twodogCfg.enable
    then ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="${version}-${suffix}" value="${pkg}/libexec/${suffix}"/>
        </packageSources>
      </configuration>
    ''
    else ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="${version}-${suffix}" value="${pkg}/libexec/${suffix}"/>
          <add key="2dog-${suffix}" value="${twodogFeed}"/>
        </packageSources>
        <packageSourceMapping>
          <packageSource key="2dog-${suffix}">
            <package pattern="2dog"/>
            <package pattern="2dog.*"/>
            <package pattern="Godot.*"/>
            <package pattern="GodotSharp*"/>
          </packageSource>
          <packageSource key="nuget.org">
            <package pattern="*"/>
          </packageSource>
        </packageSourceMapping>
      </configuration>
    '';
in {
  options.programs.godot4-mono-schnozzlecat = {
    enable = mkEnableOption (lib.mdDoc ''Godot4-mono SchnozzleCat'');
    version = mkOption {
      type = types.str;
      default = "4.7";
      description = "Version prefix. Must match a directory in pkgs/godot4-mono-schnozzlecat/ and the Godot version being built.";
    };
    # Exposed so consumers (the jailed pi coding agent, see
    # lib/jailed-pi.nix) can wire the custom fork's NuGet packages into
    # their sandbox's dotnet toolchain:
    #   (pkgs.makeJailedPi {
    #     nugetPackages = config.programs.godot4-mono-schnozzlecat.nugetPackages;
    #   })
    nugetPackages = mkOption {
      type = types.listOf types.package;
      default = [pkg];
      description = lib.mdDoc ''
        Packages whose `share/nuget` trees (the custom fork's locally
        versioned Godot.NET.Sdk / GodotSharp nupkgs) are exposed to tools
        running inside the jailed pi coding agent. Defaults to the built
        mono editor; set to `[]` to keep them out of the jail.
      '';
    };
    # The exact editor derivation this module installs on the host (same rev
    # + Tracy flags as the nugetPackages default above). Exposed so
    # consumers can put the SAME build on the jailed pi agent's sandbox
    # PATH (see home/linus.nix) instead of re-deriving a variant with
    # different rev/tracy flags.
    editorPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = pkg;
      description = lib.mdDoc ''
        The custom fork's mono editor package (`godot-mono` with all
        configured source/profiler overrides applied). Read-only: consumers
        forward this package, they don't change it.
      '';
    };
    rev = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Override the godot source commit. Defaults to the rev pinned in the
        version directory (pkgs/godot4-mono-schnozzlecat/<version>/default.nix).
        When set, `hash` must be set to the matching source hash.
      '';
    };
    hash = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Source hash for `rev`. Only needed when `rev` is overridden.";
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

    twodog = {
      enable = mkEnableOption (lib.mdDoc ''
        2dog (https://2dog.dev) built against this fork: a local NuGet feed
        with the `2dog` tool, templates, engine and natives (linux-x64,
        win-x64, browser-wasm) plus the fork's Godot.NET.Sdk, wired into
        ~/NuGet.Config with package source mapping, so `dnx 2dog new/add
        ...`, `dotnet run` and `dotnet publish` of the hosts use the fork
        (the 2dog/Godot package ids resolve from the local feed only). Also provides the .NET wasm-tools workload packs
        for browser hosts (DOTNETSDK_WORKLOAD_PACK_ROOTS), since workloads
        cannot be installed into the Nix store SDK.
      '');
      withWindows = mkOption {
        type = types.bool;
        default = true;
        description = "Build the win-x64 natives (MinGW cross build). Without, 2dog.win-x64 is an empty stub.";
      };
      withWeb = mkOption {
        type = types.bool;
        default = true;
        description = "Build the browser-wasm natives (emscripten 3.1.56 static libgodot).";
      };
      withWebThreads = mkOption {
        type = types.bool;
        default = true;
        description = "Also build the multithreaded web payload (WasmEnableThreads hosts).";
      };
      withWebGpu = mkOption {
        type = types.bool;
        default = true;
        description = "Include the WebGPU rendering driver (native Dawn on desktop, emdawnwebgpu on web), like 2dog's official builds.";
      };
      package = mkOption {
        type = types.package;
        readOnly = true;
        default = twodogPkg;
        description = lib.mdDoc ''
          The 2dog NuGet feed package (`share/2dog-feed`). Its
          `passthru` exposes `twodogVersion` (the version `dnx 2dog@...`
          takes), `godotSdkVersion` and the individual native builds.
        '';
      };
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
    (mkIf twodogCfg.enable {
      # The global ~/NuGet.Config written above is the first config NuGet
      # reads after the project's own ones; it already carries the 2dog
      # feed + mapping (see nugetConfig).
      #
      # wasm-tools for `dotnet publish` of browser-wasm hosts: the SDK picks
      # workload packs up from these roots even when `dotnet workload list`
      # shows nothing (2dog's `add --web` merely prints a hint then).
      home.sessionVariables.DOTNETSDK_WORKLOAD_PACK_ROOTS = "${twodogPkg.passthru.wasmPackRoot}";
      # (fish does not read home.sessionVariables)
      programs.fish.interactiveShellInit = ''
        set -gx DOTNETSDK_WORKLOAD_PACK_ROOTS ${twodogPkg.passthru.wasmPackRoot}
      '';
      # `dnx 2dog ...` already resolves the fork's tool (source mapping:
      # the `2dog` id only comes from the local feed). `2dog-fork` pins the
      # exact version for when the feed holds several builds (it doesn't,
      # but project-level nuget.configs can add other feeds).
      home.packages = [
        (pkgs.writeShellScriptBin "2dog-fork" ''
          exec dotnet dnx --yes "2dog@${twodogPkg.passthru.twodogVersion}" "$@"
        '')
      ];
    })
  ]);
}
