{
  alsa-lib,
  autoPatchelfHook,
  buildPackages,
  callPackage,
  dbus,
  dotnetCorePackages,
  embree,
  enet,
  exportTemplatesHash,
  fetchFromGitHub,
  fetchpatch,
  fontconfig,
  freetype,
  glib,
  glslang,
  graphite2,
  harfbuzz,
  hash,
  icu,
  installShellFiles,
  lib,
  libdecor,
  libGL,
  libjpeg_turbo,
  libpulseaudio,
  libtheora,
  libwebp,
  libX11,
  libXcursor,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libxkbcommon,
  libXrandr,
  libXrender,
  makeWrapper,
  mbedtls,
  mesaNir ? null,
  miniupnpc,
  openxr-loader,
  pcre2,
  perl,
  pkg-config,
  recastnavigation,
  runCommand,
  scons,
  sdl3,
  speechd-minimal,
  stdenv,
  stdenvNoCC,
  testers,
  udev,
  updateScript,
  version,
  vulkan-loader,
  wayland,
  wayland-scanner,
  withAlsa ? true,
  withDbus ? true,
  withFontconfig ? true,
  withMono ? false,
  nugetDeps ? null,
  withPlatform ? "linuxbsd",
  withPrecision ? "single",
  withPulseaudio ? true,
  withSpeechd ? true,
  withTouch ? true,
  withUdev ? true,
  # Wayland in Godot requires X11 until upstream fix is merged
  # https://github.com/godotengine/godot/pull/73504
  withWayland ? true,
  withX11 ? true,
  wslay,
  zstd,
  requireFile,
  unzip,
  rev,
  # Source tree of the Tracy profiler (wolfpld/tracy), required when
  # `withTracy` is enabled:
  # https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
  tracy ? null,
  # TRACY_CALLSTACK: makes every profile zone capture a callstack. Extremely
  # useful for attribution, but very expensive while a profiler is connected
  # (a 62-frame unwind per zone). Does NOT affect Tracy's periodic system
  # sampler (TracySysTrace), which is enabled by default anyway.
  withTracySampleCallstack ? false,
  # GODOT_PROFILER_TRACK_MEMORY: queue an event for every engine
  # allocation/free. Moderate overhead while connected; useless when not.
  withTracyTrackMemory ? false,
  # Export Tracy's C API (the `___tracy_*` symbols) from the built binary so
  # that e.g. C# code running inside a Godot game can P/Invoke into the
  # engine's single Tracy client instead of instantiating its own (which
  # would fight over the profiler's listen port and split the timeline).
  # Linux: links with --export-dynamic. Windows: nothing extra is needed —
  # TRACY_EXPORTS's __declspec(dllexport) directives already build a minimal
  # export table (note that --export-all-symbols does NOT work: Godot has
  # >65535 symbols, beyond the PE export ordinal limit, so ld fails with
  # "export ordinal too large").
  withTracyExportCapi ? false,
  # Generated C# API bindings ("mono glue") produced by a Linux editor build
  # of the same source rev. Required for editor builds with mono on the
  # windows platform, because glue generation requires running the built
  # editor binary (impossible without wine when cross-compiling).
  mono-glue ? null,
  withTracy ? false,
}:
assert lib.asserts.assertOneOf "withPrecision" withPrecision [
  "single"
  "double"
];
assert withTracy -> tracy != null;
assert withTracyExportCapi -> withTracy;
assert withTracySampleCallstack -> withTracy;
assert withTracyTrackMemory -> withTracy; let
  # Where the Tracy sources are copied to in preConfigure, and how they are
  # addressed from there. The relative form is needed because
  # `core/profiling/SCsub` resolves `profiler_path` with pathlib relative to
  # its own directory (see its `../../thirdparty/perfetto` default). The
  # sources must live inside the (writable) source tree: SCons derives
  # object file paths from the source location, so pointing profiler_path at
  # the read-only store path would make it try to write TracyClient.*.o into
  # /nix/store.
  tracyDir = "profiler-tracy";
  tracyDirFromScsub = "../../${tracyDir}";
  mkSconsFlagsFromAttrSet = lib.mapAttrsToList (
    k: v:
      if builtins.isString v
      then "${k}=${v}"
      else "${k}=${builtins.toJSON v}"
  );

  sdk = requireFile {
    name = "steamworks_sdk_164.zip";
    message = "Please download the SDK and then add it with nix-store --add-fixed sha256 steamworks_sdk_164.zip";
    # `sha256sum` on the path
    sha256 = "55c525b61de0fc820099b84ebd2cbd3890b9378dd3d12909c0f33d74ea05243c";
  };

  isWindows = withPlatform == "windows";

  # For platform=windows this derivation must be evaluated in a cross
  # environment (e.g. via pkgs.pkgsCross.mingwW64.callPackage), so that
  # `stdenv` is the x86_64-w64-mingw32 cross stdenv. SCons uses its own
  # arch names for the windows platform.
  arch =
    if isWindows
    then
      {
        x86_64 = "x86_64";
        aarch64 = "arm64";
        i686 = "x86_32";
      }
      .${stdenv.hostPlatform.parsed.cpu.name}
    else stdenv.hostPlatform.linuxArch;

  dotnet-sdk =
    if withMono
    then dotnetCorePackages.sdk_8_0-source
    else null;
  dotnet-sdk_alt =
    if withMono
    then dotnetCorePackages.sdk_9_0-source
    else null;

  combined-sdk =
    if withMono
    then
      dotnetCorePackages.combinePackages [
        dotnet-sdk
        dotnet-sdk_alt
        dotnetCorePackages.sdk_10_0-source
      ]
    else null;

  dottedVersion = lib.replaceStrings ["-"] ["."] version + lib.optionalString withMono ".mono";

  harfbuzz-raster = harfbuzz.override {
    withRaster = lib.versionAtLeast version "4.7";
    withCairo = lib.versionAtLeast version "4.7";
  };

  harfbuzz-icu = harfbuzz-raster.override {
    withIcu = true;
    harfbuzz = harfbuzz-raster;
  };

  mkTarget = target: let
    editor = target == "editor";
    suffix = lib.optionalString withMono "-mono" + lib.optionalString (!editor) "-template";
    binary = lib.concatStringsSep "." (
      [
        "godot"
        withPlatform
        target
      ]
      ++ lib.optional (withPrecision != "single") withPrecision
      ++ [arch]
      ++ lib.optional withMono "mono"
    );
    # The actual file name of the built binary (`bin/`); windows binaries
    # additionally carry the `.exe` extension.
    binaryExe = binary + lib.optionalString isWindows ".exe";

    mkTests = pkg: dotnet-sdk:
      lib.optionalAttrs (!isWindows)
      # Running the built binaries for tests requires an emulator (e.g. wine)
      # when cross-compiling for windows, which we don't support here.
      {
        version = testers.testVersion {
          package = pkg;
          version = dottedVersion;
        };
      }
      // lib.optionalAttrs (editor && !isWindows) (
        let
          project-src =
            runCommand "${pkg.name}-project-src"
            {
              nativeBuildInputs = [pkg] ++ lib.optional (dotnet-sdk != null) dotnet-sdk;
            }
            (
              ''
                mkdir "$out"
                cd "$out"
                touch project.godot

                cat >create-scene.gd <<'EOF'
                extends SceneTree

                func _initialize():
                  var node = Node.new()
                  var script = ResourceLoader.load("res://test.gd")
                  node.set_script(script)
              ''
              + lib.optionalString withMono ''
                ${""}
                  var monoNode = Node.new()
                  var monoScript = ResourceLoader.load("res://Test.cs")
                  monoNode.set_script(monoScript)
                  node.add_child(monoNode)
                  monoNode.owner = node
              ''
              + ''
                  var scene = PackedScene.new()
                  var scenePath = "res://test.tscn"
                  scene.pack(node)
                  node.free()
                  var x = ResourceSaver.save(scene, scenePath)
                  ProjectSettings["application/run/main_scene"] = scenePath
                  ProjectSettings.save()
                  quit()
                EOF

                cat >test.gd <<'EOF'
                extends Node
                func _ready():
                  print("Hello, World!")
                  get_tree().quit()
                EOF

                cat >export_presets.cfg <<'EOF'
                [preset.0]
                name="build"
                platform="Linux"
                runnable=true
                export_filter="all_resources"
                include_filter=""
                exclude_filter=""
                [preset.0.options]
                binary_format/architecture="${arch}"
                EOF
              ''
              + lib.optionalString withMono ''
                cat >Test.cs <<'EOF'
                using Godot;
                using System;

                public partial class Test : Node
                {
                  public override void _Ready()
                  {
                    GD.Print("Hello, Mono!");
                    GetTree().Quit();
                  }
                }
                EOF

                sdk_version=$(basename ${pkg}/share/nuget/packages/godot.net.sdk/*)
                cat >UnnamedProject.csproj <<EOF
                <Project Sdk="Godot.NET.Sdk/$sdk_version">
                  <PropertyGroup>
                    <TargetFramework>net${lib.versions.majorMinor (lib.defaultTo pkg.dotnet-sdk dotnet-sdk).version}</TargetFramework>
                    <EnableDynamicLoading>true</EnableDynamicLoading>
                  </PropertyGroup>
                </Project>
                EOF

                configureNuget

                dotnet new sln -n UnnamedProject
                message=$(dotnet sln add UnnamedProject.csproj)
                echo "$message"
                # dotnet sln doesn't return an error when it fails to add the project
                [[ $message == "Project \`UnnamedProject.csproj\` added to the solution." ]]

                rm nuget.config
              ''
            );

          export-tests = lib.makeExtensible (final: {
            inherit (pkg) export-template;

            export = stdenvNoCC.mkDerivation {
              name = "${final.export-template.name}-export";

              nativeBuildInputs = [pkg] ++ lib.optional (dotnet-sdk != null) dotnet-sdk;

              src = project-src;

              buildPhase = ''
                runHook preBuild

                export HOME=$(mktemp -d)
                mkdir -p $HOME/.local/share/godot/
                ln -s "${final.export-template}"/share/godot/export_templates "$HOME"/.local/share/godot/

                godot${suffix} --headless --build-solutions -s create-scene.gd

                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall

                mkdir -p "$out"/bin
                godot${suffix} --headless --export-release build "$out"/bin/test

                runHook postInstall
              '';
            };

            run = runCommand "${final.export.name}-runs" {passthru = {inherit (final) export;};} (
              ''
                (
                  set -eo pipefail
                  HOME=$(mktemp -d)
                  "${final.export}"/bin/test --headless | tail -n+3 | (
              ''
              + lib.optionalString withMono ''
                # indent
                    read output
                    if [[ "$output" != "Hello, Mono!" ]]; then
                      echo "unexpected output: $output" >&2
                      exit 1
                    fi
              ''
              + ''
                    read output
                    if [[ "$output" != "Hello, World!" ]]; then
                      echo "unexpected output: $output" >&2
                      exit 1
                    fi
                  )
                  touch "$out"
                )
              ''
            );
          });
        in {
          export-runs = export-tests.run;

          export-bin-runs =
            (export-tests.extend (
              final: prev: {
                export-template = pkg.export-templates-bin;

                export = prev.export.overrideAttrs (prev: {
                  nativeBuildInputs =
                    prev.nativeBuildInputs or []
                    ++ [
                      autoPatchelfHook
                    ];

                  # stripping dlls results in:
                  # Failed to load System.Private.CoreLib.dll (error code 0x8007000B)
                  stripExclude = lib.optionals withMono ["*.dll"];

                  runtimeDependencies =
                    prev.runtimeDependencies or []
                    ++ map lib.getLib [
                      alsa-lib
                      libpulseaudio
                      libX11
                      libXcursor
                      libXext
                      libXi
                      libXrandr
                      udev
                      vulkan-loader
                    ];
                });
              }
            )).run;
        }
      );

    attrs = finalAttrs: rec {
      pname = "godot${suffix}";
      inherit version;
      inherit rev;

      src = fetchFromGitHub {
        owner = "SchnozzleCat";
        repo = "godot";
        inherit rev;
        inherit hash;
      };

      outputs =
        [
          "out"
        ]
        ++ lib.optional (editor && !isWindows) "man";
      # Splitting debug info uses objcopy against the built binary; that
      # doesn't work for PE (windows) binaries with the Linux host objcopy.
      separateDebugInfo = !isWindows;

      __structuredAttrs = true;

      env = {
        # Set the build name which is part of the version. In official downloads, this
        # is set to 'official'. When not specified explicitly, it is set to
        # 'custom_build'. Other platforms packaging Godot (Gentoo, Arch, Flatpack
        # etc.) usually set this to their name as well.
        #
        # See also 'methods.py' in the Godot repo and 'build' in
        # https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
        BUILD_NAME = "nixpkgs";
        GODOT_VERSION_STATUS = "schnozzlecat-${lib.substring 0 4 rev}";
      };

      preConfigure =
        ''
          echo "Extracting Steamworks SDK..."
          mkdir -p modules/godotsteam/sdk
          unzip -o ${sdk} -d modules/godotsteam
        ''
        + lib.optionalString withTracy ''
          cp -r --no-preserve=mode ${tracy} ${tracyDir}
        ''
        + lib.optionalString (editor && withMono && isWindows) ''
          # Copy the C# API bindings generated on Linux (from the `mono-glue`
          # derivation) into the source tree, matching the official
          # cross-compilation recipe:
          # https://github.com/godotengine/godot-build-scripts/blob/master/build-windows/build.sh
          cp -r ${mono-glue}/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
          cp -r ${mono-glue}/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/
        ''
        + lib.optionalString (editor && withMono) ''

          # TODO: avoid pulling in dependencies of windows-only project
          dotnet sln modules/mono/editor/GodotTools/GodotTools.sln \
            remove modules/mono/editor/GodotTools/GodotTools.OpenVisualStudio/GodotTools.OpenVisualStudio.csproj

          dotnet restore modules/mono/glue/GodotSharp/GodotSharp.sln
          dotnet restore modules/mono/editor/GodotTools/GodotTools.sln
          dotnet restore modules/mono/editor/Godot.NET.Sdk/Godot.NET.Sdk.sln
        ''
        + lib.optionalString isWindows ''
          # Godot's SCons looks for the archiver as `<target>-gcc-ar` (and
          # gcc-ranlib/gcc-nm), which the nixpkgs cross gcc wrapper does not
          # provide. Without a shim SCons would fall back to the native
          # (x86_64-linux) gcc-ar, which cannot handle PE objects. Shim them
          # with the cross binutils tools.
          shims="$PWD/.nix-mingw-shims"
          mkdir -p "$shims"
          for tool in gcc-ar gcc-ranlib gcc-nm; do
            if ! command -v "${stdenv.hostPlatform.config}-$tool" >/dev/null 2>&1; then
              ln -s "$(command -v ${stdenv.hostPlatform.config}-''${tool#gcc-})" \
                "$shims/${stdenv.hostPlatform.config}-$tool"
            fi
          done
          export PATH="$shims:$PATH"
        '';

      # Godot 4.7 with system HarfBuzz needs explicit raster linkage, but this
      # should be resolved upstream with 4.7.1.
      # See https://github.com/godotengine/godot/pull/120568
      preBuild = lib.optionalString (!isWindows && lib.versionAtLeast version "4.7") ''
        export NIX_LDFLAGS="$NIX_LDFLAGS -lharfbuzz-raster"
      '';

      # From: https://github.com/godotengine/godot/blob/4.2.2-stable/SConstruct
      sconsFlags = mkSconsFlagsFromAttrSet (
        {
          # Options from 'SConstruct'
          precision = withPrecision; # Floating-point precision level
          production = true; # Set defaults to build Godot for use in production
          platform = withPlatform;
          inherit target;
          # Windows GCC/MinGW embeds DWARF debug info into the binary itself
          # (MSVC puts it in a separate .pdb), so keeping symbols balloons the
          # exe to >1GB. Match upstream's release flags: symbols off for the
          # editor and the release template, kept for template_debug (whose
          # purpose is debugging exported games).
          # Tracy builds always keep symbols: they are needed for Tracy's
          # sampling features to work.
          # https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
          debug_symbols = withTracy || !isWindows || target == "template_debug";

          module_mono_enabled = withMono;

          # aliasing bugs exist with hardening+LTO
          # https://github.com/godotengine/godot/pull/104501
          ccflags = "-fno-strict-aliasing";
          linkflags =
            "-Wl,--build-id"
            + lib.optionalString (withTracy && withTracyExportCapi)
            (if isWindows
            then "" # dllexport directives from TRACY_EXPORTS suffice on PE
            else " -Wl,--export-dynamic");

          # libraries that aren't available in nixpkgs
          builtin_msdfgen = true;
          builtin_rvo2_2d = true;
          builtin_rvo2_3d = true;
          builtin_xatlas = true;

          # using system clipper2 is currently not implemented
          builtin_clipper2 = true;
        }
        // (
          if isWindows
          then {
            # Options from 'platform/windows/detect.py'
            # Always explicit: auto-detection would use the build host's
            # architecture, not the target's.
            arch = arch;
            use_mingw = true; # We always cross-compile with MinGW from Linux
            # D3D12 is enabled by passing the prebuilt Mesa/NIR static
            # libraries (godot-nir-static, see d3d12-deps.nix). With this
            # set, detect.py's d3d12 default of "true" works as-is.
            mesa_libs = "${mesaNir}/mesa-x86_64-gcc";
            # LTO "auto" enables full LTO for MinGW builds, which is fragile
            # (see GH-102867). Keep the windows builds simple instead.
            lto = "none";
          }
          else {
            # Options from 'platform/linuxbsd/detect.py'
            alsa = withAlsa;
            dbus = withDbus; # Use D-Bus to handle screensaver and portal desktop settings
            fontconfig = withFontconfig; # Use fontconfig for system fonts support
            pulseaudio = withPulseaudio; # Use PulseAudio
            speechd = withSpeechd; # Use Speech Dispatcher for Text-to-Speech support
            touch = withTouch; # Enable touch events
            udev = withUdev; # Use udev for gamepad connection callbacks
            wayland = withWayland; # Compile with Wayland support
            x11 = withX11; # Compile with X11 support

            use_sowrap = false;
          }
        )
        // lib.optionalAttrs (lib.versionOlder version "4.4") {
          # libraries that aren't available in nixpkgs
          builtin_squish = true;

          # broken with system packages
          builtin_miniupnpc = true;
        }
        // lib.optionalAttrs (lib.versionAtLeast version "4.5") {
          redirect_build_objects = false; # Avoid copying build objects to output
        }
        # Built-in Tracy profiler support. `profiler_path` must not be set
        # without `profiler`, so both are only passed when enabled.
        # The `profiler_record_on_demand` option (TRACY_ON_DEMAND) defaults to
        # true upstream, which keeps memory usage bounded when the game runs
        # without a connected Tracy server.
        # https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
        // lib.optionalAttrs withTracy {
          profiler = "tracy";
          profiler_path = tracyDirFromScsub;
          profiler_sample_callstack = withTracySampleCallstack;
          profiler_track_memory = withTracyTrackMemory;
        }
      );

      enableParallelBuilding = true;

      strictDeps = true;

      patches =
        lib.optionals (lib.versionOlder version "4.6") [
          ./Linux-fix-missing-library-with-builtin_glslang-false.patch
        ]
        ++ lib.optionals (lib.versionOlder version "4.4") [
          (fetchpatch {
            name = "wayland-header-fix.patch";
            url = "https://github.com/godotengine/godot/commit/6ce71f0fb0a091cffb6adb4af8ab3f716ad8930b.patch";
            hash = "sha256-hgAtAtCghF5InyGLdE9M+9PjPS1BWXWGKgIAyeuqkoU=";
          })
          (fetchpatch {
            name = "thorvg-header-fix.patch";
            url = "https://github.com/godotengine/godot/commit/1823460787a6c1bb8e4eaf21ac2a3f90d24d5ee0.patch";
            hash = "sha256-PcHEMXd0v2c3j6Eitxt5uWi6cD+OmsBAn3TNMNRNPog=";
          })
          # Fix a crash in the mono test project build. It no longer seems to
          # happen in 4.4, but an existing fix couldn't be identified.
          ./CSharpLanguage-fix-crash-in-reload_assemblies-after-.patch
        ];

      postPatch =
        ''
          # this stops scons from hiding e.g. NIX_CFLAGS_COMPILE
          perl -pi -e '{ $r += s:(env = Environment\(.*):\1\nenv["ENV"] = os.environ: } END { exit ($r != 1) }' SConstruct
        ''
        + lib.optionalString withTracy ''
          # Upstream only links psapi/dbghelp for debug-feature builds (see
          # the `env.debug_features` and `editor/template_debug` gates in
          # platform/windows/detect.py), but TracyClient.cpp references
          # dbghelp symbols regardless of target, so the release template
          # fails to link without them.
          substituteInPlace platform/windows/detect.py \
            --replace-fail 'if env.debug_features:' 'if env.debug_features or env["profiler"] == "tracy":' \
            --replace-fail 'if env["target"] in ["editor", "template_debug"]:' 'if env["target"] in ["editor", "template_debug"] or env["profiler"] == "tracy":'
        ''
        + lib.optionalString (withTracy && withTracyExportCapi) ''
          # Build TracyClient.cpp with TRACY_EXPORTS so the C API functions
          # (`___tracy_*`, used by the TracyC.h macro layer) are exported from
          # the final binary for external consumers (e.g. C# P/Invoke).
          substituteInPlace core/profiling/SCsub \
            --replace-fail \
              'env_tracy.Append(CPPDEFINES=["TRACY_ENABLE"])' \
              'env_tracy.Append(CPPDEFINES=["TRACY_ENABLE", "TRACY_EXPORTS"])'
        ''
        # The windows build uses all builtin (vendored) libraries, since
        # cross-compiled system libraries for mingw are not available in
        # nixpkgs.
        + lib.optionalString (!isWindows) ''
          # disable all builtin libraries by default
          perl -pi -e '{ $r |= s:(opts.Add\(BoolVariable\("builtin_.*, )True(\)\)):\1False\2: } END { exit ($r != 1) }' SConstruct
        ''
        + lib.optionalString (!isWindows && lib.versionOlder version "4.6") ''
          substituteInPlace platform/linuxbsd/detect.py \
            --replace-fail /usr/include/recastnavigation ${lib.escapeShellArg (lib.getDev recastnavigation)}/include/recastnavigation

        ''
        + lib.optionalString (!isWindows) ''
          ${lib.optionalString (libGL != null) ''
            substituteInPlace thirdparty/glad/egl.c \
              --replace-fail \
                'static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"}' \
                'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libEGL.so"}'

            substituteInPlace thirdparty/glad/gl.c \
              --replace-fail \
                'static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"}' \
                'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libGLESv2.so"}' \

            substituteInPlace thirdparty/glad/gl{,x}.c \
              --replace-fail \
                '"libGL.so.1"' \
                '"${lib.getLib libGL}/lib/libGL.so"'
          ''}

          substituteInPlace thirdparty/volk/volk.c \
            --replace-fail \
              'dlopen("libvulkan.so.1"' \
              'dlopen("${lib.getLib vulkan-loader}/lib/libvulkan.so"'
        '';

      depsBuildBuild =
        lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
          buildPackages.stdenv.cc
        ]
        # pkg-config is only needed by the linuxbsd build (system libraries);
        # the windows build uses builtin libraries exclusively.
        ++ lib.optionals (!isWindows && stdenv.buildPlatform != stdenv.hostPlatform) [
          pkg-config
        ];

      buildInputs =
        lib.optionals (!isWindows) [
          embree
          enet
          freetype
          glslang
          graphite2
          harfbuzz-icu
          icu
          libtheora
          libwebp
          mbedtls
          miniupnpc
          openxr-loader
          pcre2
          recastnavigation
          wslay
          zstd
        ]
        ++ lib.optionals (!isWindows && lib.versionAtLeast version "4.5") [
          libjpeg_turbo
          sdl3
        ]
        ++ lib.optionals (!isWindows && editor && withMono) combined-sdk.packages
        ++ lib.optionals (!isWindows) (
          lib.optional withAlsa alsa-lib
          ++ lib.optional (withX11 || withWayland) libxkbcommon
          ++ lib.optionals withX11 [
            libX11
            libXcursor
            libXext
            libXfixes
            libXi
            libXinerama
            libXrandr
            libXrender
          ]
          ++ lib.optionals withWayland [
            libdecor
            wayland
          ]
          ++ lib.optionals withDbus [
            dbus
          ]
          ++ lib.optionals withFontconfig [
            fontconfig
          ]
          ++ lib.optional withPulseaudio libpulseaudio
          ++ lib.optionals withSpeechd [
            speechd-minimal
            glib
          ]
          ++ lib.optional withUdev udev
        );

      nativeBuildInputs =
        [
          perl
          scons
          unzip
        ]
        ++ lib.optionals (!isWindows) [
          installShellFiles
          pkg-config
        ]
        ++ lib.optionals (!isWindows && withWayland) [wayland-scanner]
        ++ lib.optionals (editor && withMono) [
          combined-sdk
        ]
        ++ lib.optionals (!isWindows && editor && withMono) [
          makeWrapper
        ];

      postBuild =
        lib.optionalString (editor && withMono)
          # The steam_api library must live next to the built binary.
          (
            if isWindows
            then ''
              cp modules/godotsteam/sdk/redistributable_bin/win64/steam_api64.dll bin/
            ''
            else ''
              cp modules/godotsteam/sdk/redistributable_bin/linux64/libsteam_api.so bin/libsteam_api.so
            ''
          )
        + lib.optionalString (editor && withMono) (
          if isWindows
          then
            # Glue was pre-generated on Linux (see the `mono-glue` argument);
            # only the C#/.NET assemblies need building here, targeting the
            # windows runtime. Matches the official cross-compile recipe:
            # https://github.com/godotengine/godot-build-scripts/blob/master/build-windows/build.sh
            ''
              echo "Building C#/.NET Assemblies"
              python modules/mono/build_scripts/build_assemblies.py --godot-output-dir bin --precision=${withPrecision} --godot-platform=windows --push-nupkgs-local $GODOT_VERSION_STATUS
            ''
          else ''
            echo "Generating Glue"
            bin/${binaryExe} --headless --generate-mono-glue modules/mono/glue
            echo "Building C#/.NET Assemblies"
            python modules/mono/build_scripts/build_assemblies.py --godot-output-dir bin --precision=${withPrecision} --push-nupkgs-local $GODOT_VERSION_STATUS
          ''
        )
        # The windows export templates also link against steam_api64, so the
        # runtime DLL has to be shipped next to them (the editor's export
        # logic will include it in exported games alongside steam_api64.dll).
        + lib.optionalString (!editor && isWindows) ''
          cp modules/godotsteam/sdk/redistributable_bin/win64/steam_api64.dll bin/
        '';

      installPhase =
        if isWindows
        then
          if editor
          then
            # The windows editor is meant to be copied to a Windows machine as
            # a self-contained directory (exe + console.exe + GodotSharp data
            # dir + steam_api64.dll), so install everything flat. This also
            # matches the official release layout (GodotSharp with
            # `Tools/nupkgs` kept in place).
            ''
              runHook preInstall

              mkdir -p "$out"
              cp -r bin/* "$out"/
            ''
          else
            # Windows export template names use underscores and the .exe
            # extension, e.g. windows_release_x86_64.exe — exactly what the
            # "Windows Desktop" exporter expects inside export_templates.
            let
              templateKind =
                if target == "template_release"
                then "release"
                else "debug";
            in ''
              runHook preInstall

              templates="$out"/share/godot/export_templates/${dottedVersion}
              mkdir -p "$templates"
              cp bin/${binary}.exe "$templates"/windows_${templateKind}_${arch}.exe
              cp bin/${binary}.console.exe "$templates"/windows_${templateKind}_${arch}_console.exe
              # Kept next to the templates for convenience; the steam_api64
              # runtime DLL must be present next to exported games when using
              # GodotSteam on Windows.
              cp bin/steam_api64.dll "$templates"/steam_api64.dll
            ''
        else
          ''
          runHook preInstall

          mkdir -p "$out"/{bin,libexec}
          cp -r bin/* "$out"/libexec
        ''
        + (
          if editor
          then ''
            echo "$GODOT_VERSION_STATUS" > "$out"/libexec/.godot_version_status
            cp -r "$GODOT_VERSION_STATUS" "$out"/libexec/"$GODOT_VERSION_STATUS"
          ''
          else ''''
        )
        + ''
          cd "$out"/bin
          ln -s ../libexec/${binary} godot${lib.versions.majorMinor version}${suffix}
          ln -s godot${lib.versions.majorMinor version}${suffix} godot${lib.versions.major version}${suffix}
          ln -s godot${lib.versions.major version}${suffix} godot${suffix}
          cd -
        ''
        + (
          if editor
          then
            ''
              installManPage misc/dist/linux/godot.6

              mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
              cp misc/dist/linux/org.godotengine.Godot.desktop \
                "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop"

              substituteInPlace "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop" \
                --replace-fail "Exec=godot" "Exec=$out/bin/godot${suffix}" \
                --replace-fail "Godot Engine" "Godot Engine ${
                lib.versions.majorMinor version + lib.optionalString withMono " (Mono)"
              }"
              ${
                if lib.versionOlder version "4.7"
                then ''
                  cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
                  cp icon.png "$out/share/icons/godot.png"
                ''
                else ''
                  cp misc/logo/icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
                  cp misc/logo/icon.png "$out/share/icons/godot.png"
                ''
              }
            ''
            + lib.optionalString withMono ''
              mkdir -p "$out"/share/nuget
              mv "$out"/libexec/GodotSharp/Tools/nupkgs "$out"/share/nuget/source

              wrapProgram "$out"/libexec/${binary} \
                --prefix NUGET_FALLBACK_PACKAGES ';' "$out"/share/nuget/packages/
            ''
          else let
            template =
              (
                lib.replaceStrings
                ["template"]
                [
                  {
                    linuxbsd = "linux";
                  }
                    .${
                    withPlatform
                  }
                ]
                target
              )
              + "."
              + arch;
          in ''
            templates="$out"/share/godot/export_templates/${dottedVersion}
            mkdir -p "$templates"
            ln -s "$out"/libexec/${binary} "$templates"/${template}
          ''
        )
        + ''
          runHook postInstall
        '';

      passthru =
        {
          inherit updateScript;
          tests =
            mkTests finalAttrs.finalPackage dotnet-sdk
            // lib.optionalAttrs (editor && withMono) {
              sdk-override = mkTests finalAttrs.finalPackage dotnet-sdk_alt;
            };
        }
        // lib.optionalAttrs editor {
          export-template = mkTarget "template_release";
          export-template-debug = mkTarget "template_debug";
          export-templates-bin = (
            callPackage ./export-templates-bin.nix {
              inherit version rev withMono;
              godot = finalAttrs.finalPackage;
              hash = exportTemplatesHash;
            }
          );
        };

      requiredSystemFeatures = [
        # fixes: No space left on device
        "big-parallel"
      ];

      meta = {
        changelog = "https://github.com/godotengine/godot/releases/tag/${version}";
        description = "Free and Open Source 2D and 3D game engine";
        homepage = "https://godotengine.org";
        license = lib.licenses.mit;
        platforms =
          if isWindows
          then ["x86_64-windows"]
          else
            [
              "x86_64-linux"
              "aarch64-linux"
            ]
            ++ lib.optional (!withMono) "i686-linux";
        maintainers = with lib.maintainers; [
          shiryel
          corngood
        ];
        mainProgram = "godot${suffix}";
      };
    };

    unwrapped = stdenv.mkDerivation (
      if (editor && withMono)
      then
        dotnetCorePackages.addNuGetDeps {
          inherit nugetDeps;
          overrideFetchAttrs = old: rec {
            runtimeIds =
              if isWindows
              then
                # linux-x64: the rid of the build host performing the restore;
                # win-x64: the rid of the produced assemblies.
                ["linux-x64" "win-x64"]
              else map (system: dotnetCorePackages.systemToDotnetRid system) old.meta.platforms;
            buildInputs =
              old.buildInputs
              ++ lib.concatLists (lib.attrValues (lib.getAttrs runtimeIds combined-sdk.targetPackages));
          };
        }
        attrs
      else attrs
    );

    wrapper =
      if (editor && withMono && !isWindows)
      then
        stdenv.mkDerivation (finalAttrs: {
          __structuredAttrs = true;

          pname = finalAttrs.unwrapped.pname + "-wrapper";
          inherit
            (finalAttrs.unwrapped)
            version
            rev
            outputs
            meta
            ;
          inherit unwrapped combined-sdk;

          dontUnpack = true;
          dontConfigure = true;
          dontBuild = true;

          nativeBuildInputs = [makeWrapper];
          strictDeps = true;

          installPhase = ''
            runHook preInstall

            mkdir -p "$out"/{bin,libexec,share/applications,nix-support}

            cp -d "$unwrapped"/bin/* "$out"/bin/
            ln -s "$unwrapped"/libexec/* "$out"/libexec/
            ln -s "$unwrapped"/share/nuget "$out"/share/
            cp "$unwrapped/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop" \
              "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop"

            substituteInPlace "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop" \
              --replace-fail "Exec=$unwrapped/bin/godot${suffix}" "Exec=$out/bin/godot${suffix}"
            ln -s "$unwrapped"/share/icons $out/share/

            # ensure dotnet hooks get run
            echo "${finalAttrs.combined-sdk}" >> "$out"/nix-support/propagated-build-inputs

            wrapProgram "$out"/libexec/${binary} \
              --prefix PATH : "${lib.makeBinPath [finalAttrs.combined-sdk]}" \
              --set-default TZDIR /etc/zoneinfo

            runHook postInstall
          '';

          postFixup =
            lib.concatMapStringsSep "\n" (output: ''
              [[ -e "''$${output}" ]] || ln -s "${unwrapped.${output}}" "''$${output}"
            '')
            finalAttrs.unwrapped.outputs;

          passthru =
            unwrapped.passthru
            // {
              tests =
                mkTests finalAttrs.finalPackage null
                // {
                  unwrapped = lib.recurseIntoAttrs unwrapped.tests;
                  sdk-override = lib.recurseIntoAttrs (
                    mkTests (finalAttrs.finalPackage.overrideAttrs {dotnet-sdk = dotnet-sdk_alt;}) null
                  );
                };
            };
        })
      else unwrapped;
  in
    wrapper;
in
  mkTarget "editor"
