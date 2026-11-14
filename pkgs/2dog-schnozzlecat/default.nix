# 2dog (https://2dog.dev) built against the SchnozzleCat godot fork.
#
# Output: a local NuGet feed (`$out/share/2dog-feed`, flat folder of
# .nupkg files) containing
#   - the 2dog packages: CLI tool (`dnx 2dog`), templates, engine, bindings,
#     integrations (xunit/nunit/gdunit/avalonia/blazor/qt/repl) and the
#     native packages for linux-x64, win-x64 (MinGW cross build) and
#     browser-wasm (emscripten 3.1.56 static libgodot) -- osx-arm64 and the
#     mobile platforms are empty stubs (cannot be built here);
#   - the fork's Godot.NET.Sdk / GodotSharp / Godot.SourceGenerators.
#
# Everything is built from the fork merged into 2dog's libgodot godot tree
# (see pins.nix / merge-sources.sh), following
# https://2dog.dev/godot-forks.html. The fork's packages get their own
# version numbers so they never collide with nuget.org's, see `forkTag`.
#
# The home-manager module (modules/home-manager/godot4-mono-schnozzlecat.nix,
# `twodog.enable`) wires the feed into ~/.nuget/NuGet/NuGet.Config with
# package source mapping and provides the wasm-tools workload packs for
# `dotnet publish` of browser hosts.
{
  lib,
  stdenv,
  stdenvNoCC,
  callPackage,
  runCommand,
  fetchFromGitHub,
  fetchurl,
  dotnetCorePackages,
  python3,
  git,
  unzip,
  xmlstarlet,
  scons,
  perl,
  steamworks-sdk,
  # Fork source to merge (defaults to pins.nix; the home-manager module
  # forwards its rev/hash overrides).
  forkRev ? null,
  forkHash ? null,
  # Which native packages contain real binaries.
  withWindows ? true,
  withWeb ? true,
  withWebThreads ? true,
  # Native desktop WebGPU (Dawn) driver, like 2dog's official builds.
  withWebGpu ? true,
}: let
  pins = import ./pins.nix;

  fork =
    pins.fork
    // lib.optionalAttrs (forkRev != null) {rev = forkRev;}
    // lib.optionalAttrs (forkHash != null) {hash = forkHash;};

  twodogSrc = fetchFromGitHub {inherit (pins.twodog) owner repo rev hash;};

  sources = callPackage ./sources.nix {inherit pins fork twodogSrc;};
  inherit (sources) godotSource wasmPackRoot emsdkEnv dawnBoundary;

  # --- versions ----------------------------------------------------------
  #
  # `dnx 2dog` (and `dotnet tool`) only pick *stable* versions without
  # --prerelease, and System.Version (used by `2dog doctor/update`) cannot
  # parse prerelease labels. So the fork's 2dog packages get a stable,
  # numerically higher-than-upstream 4th component:
  #   <revision> * 100000 + (first 4 hex digits of the fork rev, mod 100000)
  # e.g. revision 159, rev 7da4fae -> 4.7.2.15932164. It stays within
  # System.Version / NuGet's int32 range and changes with every fork rev, so
  # restores never mix fork builds (and never pick nuget.org's 4.7.2.159).
  forkTag = lib.mod (lib.fromHexString (lib.substring 0 4 fork.rev)) 100000;
  twodogVersion = "${pins.twodog.godotVersion}.${toString (pins.twodog.revision * 100000 + forkTag)}";
  nativesVersion = twodogVersion;

  # Godot.NET.Sdk & friends: build_assemblies.py derives the version from
  # GODOT_VERSION_STATUS ("schnozzlecat-7da4" -> 4.7.2-schnozzlecat-7da.4),
  # exactly like the editor package does.
  versionStatus = "schnozzlecat-${lib.substring 0 4 fork.rev}";
  # build_assemblies.py turns a trailing number in the status into its own
  # dot-separated SemVer part: "schnozzlecat-7da4" -> "schnozzlecat-7da.4".
  godotSdkVersion = let
    m = builtins.match "(.*[^0-9])([0-9]+)" versionStatus;
  in
    if m == null
    then "${pins.twodog.godotVersion}-${versionStatus}"
    else "${pins.twodog.godotVersion}-${builtins.elemAt m 0}.${builtins.elemAt m 1}";

  # --- native engine builds ------------------------------------------------
  godotPkgs = callPackage ../godot4-mono-schnozzlecat {inherit steamworks-sdk;};
  base = godotPkgs.mkGodotPackages "4.7" {inherit (fork) rev hash;};

  # Settings shared by every 2dog engine build (desktop): merged source,
  # libgodot-compatible SCons flags, raw bin/ output.
  libgodotArgs = {
    srcOverride = godotSource;
    rawOutput = true;
    withHarfbuzzVector = true;
    # Not (yet) built with the portable buildroot toolchain (common.nix
    # `portableTargets`); the Dawn boundary SDK is built with the Nix
    # toolchain.
    portableTargets = [];
  };

  webgpuFlags =
    if withWebGpu
    then {
      webgpu = true;
      webgpu_precompile = false;
      webgpu_native_path = "${dawnBoundary}";
    }
    else {webgpu = false;};

  # Mono editor of the merged tree (build_editor + generate_glue in 2dog's
  # build-godot.py): common.nix's regular editor pipeline generates the glue
  # and builds GodotSharp/GodotTools + the Godot.NET.Sdk nupkgs
  # (--push-nupkgs-local) in postBuild. No WebGPU: the generated C# API
  # does not depend on the rendering drivers. `unwrapped` is the raw build
  # (libexec/GodotSharp, share/nuget/source), not the PATH wrapper.
  #
  # The wrapped one (`editor`) is also the Godot editor for 2dog games: it
  # writes the same Godot.NET.Sdk version (4.7.2-schnozzlecat-...) the 2dog
  # packages are built against, unlike the regular fork editor (4.7.0-based).
  editor = base.godot-mono.override {
    srcOverride = godotSource;
    withHarfbuzzVector = true;
    nugetDeps = ./deps.json;
    extraSconsFlags = {
      d3d12 = false;
      webgpu = false;
    };
  };
  glueEditor = editor.unwrapped;

  # Its C# outputs in the `godot/bin` layout 2dog packs from.
  godotSharp = runCommand "godot-2dog-godotsharp-${godotSdkVersion}" {} ''
    mkdir -p $out/GodotSharp/Tools/nupkgs $out/sourcegen
    cp -r ${glueEditor}/libexec/GodotSharp/. $out/GodotSharp/
    chmod -R u+w $out/GodotSharp
    # The real nupkgs: build_assemblies.py --push-nupkgs-local copies them to
    # ./<status>/ (installed as libexec/<status>); share/nuget/source only
    # holds the restore-time stand-ins.
    cp ${glueEditor}/libexec/${versionStatus}/*.nupkg $out/GodotSharp/Tools/nupkgs/
    # Godot.SourceGenerators.dll, packed directly by 2dog.godotsharp
    ${unzip}/bin/unzip -j -o $out/GodotSharp/Tools/nupkgs/Godot.SourceGenerators.*.nupkg \
      'analyzers/dotnet/cs/Godot.SourceGenerators.dll' -d $out/sourcegen
  '';

  # libgodot shared libraries (build_libgodot in build-godot.py).
  mkLibgodot = {
    platformPkgs,
    target,
    extra ? {},
  }:
    # No Tracy: libgodot is dlopen'ed by .NET, and Tracy's rpmalloc uses
    # initial-exec TLS ("cannot allocate memory in static TLS block").
    (platformPkgs.override (libgodotArgs
      // {
        withMono = true;
        # libgodot builds compile no C# code; no NuGet deps needed.
        nugetDeps = null;
        rawTarget = target;
        extraSconsFlags =
          {
            library_type = "shared_library";
            extra_suffix = "shared_library";
            d3d12 = false;
            # 2dog builds libgodot without `production` (no LTO); common.nix
            # passes production=true, which would full-LTO the ~200 MB
            # shared library (very slow, huge RAM).
            production = false;
            lto = "none";
            # template_release is never a dev build (build-godot.py)
            dev_build = false;
            scu_build = true;
            debug_symbols = false;
            separate_debug_symbols = false;
            # Allow --path override at runtime (libgodot loads projects).
            disable_path_overrides = false;
          }
          // webgpuFlags
          // extra;
      }))
    .overrideAttrs (old: {
      pname = "libgodot-2dog-${target}";
    });

  # rawOutput disables all of common.nix's editor-only post-processing
  # (glue/assemblies/desktop files/wrapper) for the editor libgodot.
  linuxLibs = lib.genAttrs ["template_release" "template_debug" "editor"] (target:
    mkLibgodot {
      platformPkgs = base.godot;
      inherit target;
    });

  # Windows: MinGW cross build like the existing godot-mono-windows. The
  # Dawn boundary DLL comes from 2dog's own release (MSVC-only, see pins).
  twodogWinNatives = fetchurl {
    name = "2dog.win-x64.release.nupkg";
    inherit (pins.twodogWinNatives) url hash;
  };
  winDawnRuntime = stdenvNoCC.mkDerivation {
    pname = "godot-webgpu-dawn-win-x64";
    version = "f9ac6c6";
    dontUnpack = true;
    nativeBuildInputs = [unzip];
    installPhase = ''
      mkdir -p $out
      unzip -q ${twodogWinNatives} 'runtimes/win-x64/native/*' -x 'runtimes/win-x64/native/libgodot-*' -d $TMPDIR/n
      cp -r $TMPDIR/n/runtimes/win-x64/native/. $out/
    '';
  };

  # The cross build cannot run the Dawn boundary CMake build (MSVC-only), so
  # webgpu_native_path points at an SDK made of the Linux boundary headers
  # (identical, generated from the same Dawn release) + the Windows DLL.
  winDawnSdk = stdenvNoCC.mkDerivation {
    pname = "godot-webgpu-dawn-sdk-win-x64";
    version = "f9ac6c6";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp -r ${dawnBoundary}/include $out/include
      cp -r ${winDawnRuntime}/licenses $out/licenses
      cp ${winDawnRuntime}/*.dll $out/bin/
    '';
  };

  windowsLibs = lib.genAttrs ["template_release" "template_debug" "editor"] (target:
    mkLibgodot {
      platformPkgs = base.godot-mono-windows;
      inherit target;
      extra = lib.optionalAttrs withWebGpu {webgpu_native_path = "${winDawnSdk}";};
    });

  # Web (emscripten 3.1.56, static library), build_libgodot_web. WebGPU on
  # web uses the emdawnwebgpu port (pinned in the source tree), no Dawn SDK.
  mkWebLib = {
    target,
    threads,
  }:
    stdenv.mkDerivation {
      pname = "libgodot-2dog-web${lib.optionalString threads "-threads"}-${target}";
      version = twodogVersion;
      src = godotSource;
      nativeBuildInputs = [scons python3 perl unzip];
      env.GODOT_VERSION_STATUS = versionStatus;
      env.BUILD_NAME = "nixpkgs";
      enableParallelBuilding = true;
      dontConfigure = true;
      postPatch = ''
        perl -pi -e '{ $r += s:(env = Environment\(.*):\1\nenv["ENV"] = os.environ: } END { exit ($r != 1) }' SConstruct
        # The web build zips its outputs (bin/godot.web.*.zip) with the source
        # files' mtimes; store copies are dated 1970, which ZIP rejects
        # ("timestamps before 1980"). SOURCE_DATE_EPOCH is exactly
        # 1980-01-01T00:00Z, which zipfile's localtime() can push back into
        # 1979; use a fixed, still reproducible date with some margin.
        find . -exec touch -h -d 1980-01-02T00:00:00Z {} +
      '';
      buildPhase = ''
        runHook preBuild
        export HOME=$TMPDIR
        ${emsdkEnv}
        emcc --version | head -1
        scons -j$NIX_BUILD_CORES \
          platform=web arch=wasm32 target=${target} \
          module_mono_enabled=yes precision=single \
          library_type=static_library extra_suffix=static_library \
          ${
          if threads
          then "threads=yes proxy_to_pthread=yes"
          else "threads=no"
        } \
          lto=none disable_crash_handler=yes dev_build=no scu_build=yes \
          disable_path_overrides=no \
          ${
          if withWebGpu && !threads
          then "webgpu=yes webgpu_precompile=no"
          else "webgpu=no"
        }
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        zip_dir=bin/.web_zip
        test -f $zip_dir/libgodot/libgodot.a
        mkdir -p $out
        cp -r $zip_dir/libgodot $out/libgodot
        ${lib.optionalString (withWebGpu && !threads) ''
          cp -r thirdparty/emdawnwebgpu $out/libgodot/emdawnwebgpu
          find $out/libgodot/emdawnwebgpu -name __pycache__ -prune -exec rm -rf {} +
        ''}
        mkdir -p $out/shell
        for f in godot.js godot.audio.worklet.js godot.audio.position.worklet.js; do
          cp $zip_dir/$f $out/shell/
        done
        runHook postInstall
      '';
      requiredSystemFeatures = ["big-parallel"];
    };

  webLibs = lib.genAttrs ["template_release" "template_debug"] (target: mkWebLib {
    inherit target;
    threads = false;
  });
  webThreadsLibs = lib.genAttrs ["template_release" "template_debug"] (target: mkWebLib {
    inherit target;
    threads = true;
  });

  gdunitArchive = fetchurl {inherit (pins.gdunit) url sha256;};

  # --- packaging -----------------------------------------------------------
  # `godot/bin` layout that 2dog's platform projects pack from
  # (platforms/Directory.Build.targets, twodog.engine, twodog.godotsharp).
  #
  # Sidecars: everything in godot/bin/webgpu/<rid>/ is packed next to the
  # native library (runtimes/<rid>/native/) and copied beside it into the
  # host's output/publish dir by 2dog's native resolver. Besides Dawn, the
  # fork's GodotSteam module needs the Steamworks runtime there (libgodot
  # links it, RPATH $ORIGIN).
  stageGodotBin = ''
    bin=godot/bin
    mkdir -p $bin
    cp -r --no-preserve=mode ${godotSharp}/GodotSharp $bin/GodotSharp

    steam=$TMPDIR/steamworks
    mkdir -p $steam
    unzip -q -o ${steamworks-sdk} 'sdk/redistributable_bin/linux64/libsteam_api.so' \
      'sdk/redistributable_bin/win64/steam_api64.dll' -d $steam
    mkdir -p $bin/webgpu/linux-x64 $bin/webgpu/win-x64
    cp $steam/sdk/redistributable_bin/linux64/libsteam_api.so $bin/webgpu/linux-x64/
    ${lib.optionalString withWindows ''
      cp $steam/sdk/redistributable_bin/win64/steam_api64.dll $bin/webgpu/win-x64/
    ''}

    # Copies the shared libgodot of one build into the name 2dog's platform
    # projects pack from (platforms/Directory.Build.targets NativeLibPath).
    # The produced name varies (mono module suffix; SCons' mingw tool keeps
    # the host's lib*.so naming when cross-compiling from Linux), so match
    # it instead of guessing.
    stageNative() {
      local src=$1 platform=$2 target=$3 dest=$4 found
      found=$(find $src/bin -maxdepth 1 -type f \
        \( -name "*godot.$platform.$target.x86_64*.shared_library.so" \
           -o -name "*godot.$platform.$target.x86_64*.shared_library.dll" \))
      if [ "$(printf '%s\n' "$found" | grep -c .)" -ne 1 ]; then
        echo "stageNative: expected exactly one libgodot in $src/bin, found:" >&2
        ls -la $src/bin >&2
        exit 1
      fi
      echo "staging $found -> $dest"
      cp "$found" $bin/$dest
    }

    # Linux natives (+ Dawn boundary, staged like scripts/webgpu.py)
    for t in template_release template_debug editor; do
      case $t in
        template_release) src=${linuxLibs.template_release};;
        template_debug) src=${linuxLibs.template_debug};;
        editor) src=${linuxLibs.editor};;
      esac
      stageNative $src linuxbsd $t libgodot.linuxbsd.$t.x86_64.shared_library.so
    done
    ${lib.optionalString withWebGpu ''
      mkdir -p $bin/webgpu/linux-x64
      cp ${dawnBoundary}/lib/libgodot_webgpu_dawn.so $bin/webgpu/linux-x64/
      cp -r ${dawnBoundary}/licenses $bin/webgpu/linux-x64/licenses
    ''}

    ${lib.optionalString withWindows ''
      for t in template_release template_debug editor; do
        case $t in
          template_release) src=${windowsLibs.template_release};;
          template_debug) src=${windowsLibs.template_debug};;
          editor) src=${windowsLibs.editor};;
        esac
        stageNative $src windows $t godot.windows.$t.x86_64.shared_library.dll
      done
      ${lib.optionalString withWebGpu ''
        mkdir -p $bin/webgpu/win-x64
        cp -r ${winDawnRuntime}/. $bin/webgpu/win-x64/
      ''}
    ''}

    ${lib.optionalString withWeb ''
      mkdir -p $bin/web
      cp -r --no-preserve=mode ${webLibs.template_release} $bin/web/template_release
      cp -r --no-preserve=mode ${webLibs.template_debug} $bin/web/template_debug
    ''}
    ${lib.optionalString (withWeb && withWebThreads) ''
      mkdir -p $bin/web-threads
      cp -r --no-preserve=mode ${webThreadsLibs.template_release} $bin/web-threads/template_release
      cp -r --no-preserve=mode ${webThreadsLibs.template_debug} $bin/web-threads/template_debug
    ''}

    # Godot.SourceGenerators.dll where twodog.godotsharp looks for it
    gen=godot/modules/mono/editor/Godot.NET.Sdk/Godot.SourceGenerators/bin/Release/netstandard2.0
    mkdir -p $gen
    cp ${godotSharp}/sourcegen/Godot.SourceGenerators.dll $gen/
  '';

  feed = stdenv.mkDerivation (finalAttrs: {
    pname = "2dog-schnozzlecat";
    version = twodogVersion;
    src = twodogSrc;

    nativeBuildInputs = [
      dotnetCorePackages.sdk_10_0-source
      python3
      git
      xmlstarlet
      unzip
    ];
    # NuGet deps of the managed 2dog projects + the fork's Godot packages.
    buildInputs =
      (map dotnetCorePackages.fetchNupkg (lib.importJSON ./deps.json));

    dontConfigureNuget = true;

    postPatch = ''
      # Package versions (see `forkTag`): stable, fork-specific. GodotVersion
      # is what the CLI/templates scaffold as Godot.NET.Sdk/<version>, so it
      # must be the fork's SDK package version.
      substituteInPlace Directory.Build.props \
        --replace-fail '<TwoDogVersion>$(GodotVersion).$(TwoDogRevision)</TwoDogVersion>' \
                       '<TwoDogVersion>${twodogVersion}</TwoDogVersion>' \
        --replace-fail '<NativesVersion>$(GodotVersion).$(NativesRevision)</NativesVersion>' \
                       '<NativesVersion>${nativesVersion}</NativesVersion>' \
        --replace-fail '<GodotVersion>${pins.twodog.godotVersion}</GodotVersion>' \
                       '<GodotVersion>${godotSdkVersion}</GodotVersion>'

      # Assembly/file version parts are limited to 65535 (CS7034), so keep
      # them at upstream's numbers; only the NuGet versions carry forkTag.
      substituteInPlace Directory.Build.props \
        --replace-fail '<RollForward>LatestMajor</RollForward>' \
                       '<RollForward>LatestMajor</RollForward>
        <AssemblyVersion>${pins.twodog.godotVersion}.${toString pins.twodog.revision}</AssemblyVersion>
        <FileVersion>${pins.twodog.godotVersion}.${toString pins.twodog.revision}</FileVersion>'
    '';

    configurePhase = ''
      runHook preConfigure
      export HOME=$TMPDIR
      export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
      export NUGET_PACKAGES=$TMPDIR/nuget-packages
      mkdir -p $NUGET_PACKAGES

      # The pinned deps, pre-extracted. fetchNupkg's share/nuget/source/*.nupkg
      # are NOT installable (they only contain the .nuspec, unless built with
      # installable = true): restoring from them "succeeds" but yields
      # packages without lib/ assets (e.g. Avalonia -> CS0246). Instead,
      # link the unpacked share/nuget/packages/<id>/<version> trees into a
      # read-only fallback packages folder, exactly like nixpkgs'
      # configureNuget does; NuGet resolves from it without any source.
      export NUGET_FALLBACK_PACKAGES=$TMPDIR/nuget-fallback/
      for d in $buildInputs; do
        for p in $d/share/nuget/packages/*/*; do
          [ -d "$p" ] || continue
          id=$(basename "$(dirname "$p")")
          mkdir -p $NUGET_FALLBACK_PACKAGES$id
          ln -sfn "$p" $NUGET_FALLBACK_PACKAGES$id/
        done
      done
      # The (nuspec-only) nupkgs as a listing source: NuGet resolves version
      # *ranges* (2dog floats e.g. AspNetCore 10.0.*, NUnit 4.*, xunit.v3
      # 3.*) by enumerating a source; the fallback folder alone cannot. The
      # chosen version is then taken from the fallback folder above, so the
      # content-less nupkgs are never extracted.
      mkdir -p $TMPDIR/nix-source
      for d in $buildInputs; do
        find -L $d/share/nuget/source -name '*.nupkg' -exec ln -sf {} $TMPDIR/nix-source/ \; 2>/dev/null || true
      done

      # 2dog's build only needs a git work tree for two checks: the native
      # packages stamp `git rev-parse HEAD:godot` (the submodule commit) as
      # their repository commit, and the tool/templates verify the template
      # files are tracked. Recreate both: commit the sources plus a `godot`
      # gitlink to the 2dog godot commit the fork was merged into.
      rm -rf godot
      git init -q
      git add -A
      git update-index --add --cacheinfo 160000,${pins.godot2dog.rev},godot
      git -c user.name=nix -c user.email=nix@localhost commit -qm src
      mkdir -p godot
      ${stageGodotBin}

      cat > nuget.config <<EOF
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <config><add key="globalPackagesFolder" value="$NUGET_PACKAGES" /></config>
        <fallbackPackageFolders>
          <clear />
          <add key="nix" value="$NUGET_FALLBACK_PACKAGES" />
        </fallbackPackageFolders>
        <packageSources>
          <clear />
          <add key="2dog Packages (local)" value="$PWD/packages/" />
          <add key="Godot Packages (local)" value="$PWD/godot/bin/GodotSharp/Tools/nupkgs/" />
          <add key="nix" value="$TMPDIR/nix-source" />
        </packageSources>
      </configuration>
      EOF
      mkdir -p packages

      # GdUnit runtime archive (normally downloaded by GdUnitRuntime.targets)
      gd=twodog.gdunit/obj/gdunit-release/single/${pins.gdunit.version}
      mkdir -p $gd
      cp ${gdunitArchive} $gd/GdUnit.${pins.gdunit.version}.zip

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      pack() { dotnet pack "$@" -c Release -p:ContinuousIntegrationBuild=true; }

      # = `uv run poe build` (minus build-maui): natives (all platforms,
      # missing ones become stubs), then the managed packages in order.
      pack platforms -p:ForcePackAllPlatforms=true
      for p in twodog.godotsharp twodog.godotsharp.editor twodog.engine \
               twodog.avalonia twodog.blazor twodog.qt twodog.xunit \
               twodog.nunit twodog.gdunit twodog.repl twodog twodog.templates; do
        pack $p
      done
      runHook postBuild
    '';

    # A *flat* folder feed: `dnx`/`dotnet tool` do not find tool packages in
    # NuGet's hierarchical (<id>/<version>/) local feed layout.
    installPhase = ''
      runHook preInstall
      # (Not share/nuget/source: nixpkgs' NuGet hooks expect that one to be
      # hierarchical.) The jailed pi bundle (lib/jailed-pi.nix) picks
      # *.nupkg up from anywhere under share/.
      mkdir -p $out/share/2dog-feed
      cp packages/*.nupkg godot/bin/GodotSharp/Tools/nupkgs/*.nupkg $out/share/2dog-feed/
      runHook postInstall
    '';

    passthru = {
      inherit
        twodogVersion
        nativesVersion
        versionStatus
        godotSource
        wasmPackRoot
        dawnBoundary
        editor
        glueEditor
        godotSharp
        linuxLibs
        windowsLibs
        webLibs
        webThreadsLibs
        ;
      inherit godotSdkVersion;
    };

    requiredSystemFeatures = ["big-parallel"];

    meta = {
      description = "2dog (Godot as a .NET library) NuGet feed built against the SchnozzleCat godot fork";
      homepage = "https://2dog.dev";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
    };
  });
in
  feed
