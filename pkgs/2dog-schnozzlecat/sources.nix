# Sources and toolchains shared by the 2dog build derivations:
#   - godotSource:  the SchnozzleCat fork merged into 2dog's libgodot tree,
#                   with the WebGPU third-party sources prepared offline
#   - wasmPackRoot: the .NET "wasm-tools" workload as a DOTNETSDK_WORKLOAD_
#                   PACK_ROOTS tree (incl. emscripten 3.1.56)
#   - emsdkEnv:     shell snippet putting that emscripten on PATH
#   - dawnBoundary: native desktop WebGPU boundary SDK (libgodot_webgpu_dawn)
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  runCommand,
  autoPatchelfHook,
  cmake,
  git,
  python3,
  unzip,
  zlib,
  pins,
  fork,
  # 2dog source tree (for the redistributable WebGPU license texts).
  twodogSrc,
}: let
  merge = ./merge-sources.sh;

  forkBaseSrc = fetchFromGitHub {inherit (pins.forkBase) owner repo rev hash;};
  forkSrc = fetchFromGitHub {inherit (fork) owner repo rev hash;};
  godot2dogSrc = fetchFromGitHub {inherit (pins.godot2dog) owner repo rev hash;};

  # dependencies.py expects archives named <sha256>.<ext> in its cache dir.
  webgpuDepsCache = runCommand "godot-webgpu-deps-cache" {} (
    ''
      mkdir -p $out
    ''
    + lib.concatStrings (lib.mapAttrsToList (name: spec: let
        ext =
          if lib.hasSuffix ".zip" spec.url
          then "zip"
          else "tar.gz";
        file = fetchurl {inherit (spec) url sha256;};
      in ''
        ln -s ${file} $out/${spec.sha256}.${ext}
      '')
      pins.webgpuDeps)
  );

  godotSource =
    runCommand "godot-2dog-schnozzlecat-src-${lib.substring 0 7 fork.rev}" {
      nativeBuildInputs = [git python3];
    } ''
      cp -r --no-preserve=mode ${godot2dogSrc} $out
      # fetchFromGitHub keeps executable bits; --no-preserve=mode drops them,
      # restore the ones scripts need.
      find ${godot2dogSrc} -type f -perm -u+x -printf '%P\0' \
        | (cd $out && xargs -0 -r chmod +x)

      bash ${merge} ${forkBaseSrc} ${forkSrc} $out

      # WebGPU sources (tint, SPIRV-Tools, SPIRV-Headers, emdawnwebgpu): not
      # vendored in git, normally downloaded by SConstruct at configure time.
      cd $out
      export HOME=$TMPDIR
      # dependencies.py stages its extraction in a temp dir *inside* the
      # cache dir, so the cache must be writable: a writable dir of symlinks
      # to the (read-only) pinned archives.
      cache=$TMPDIR/webgpu-cache
      mkdir -p $cache
      ln -s ${webgpuDepsCache}/* $cache/
      python3 drivers/webgpu/dependencies.py --cache $cache --offline
    '';

  # --- .NET wasm-tools workload pack root -------------------------------
  fetchPack = id: hash:
    fetchurl {
      name = "${lib.toLower id}.${pins.wasmPacksVersion}.nupkg";
      url = "https://api.nuget.org/v3-flatcontainer/${lib.toLower id}/${pins.wasmPacksVersion}/${lib.toLower id}.${pins.wasmPacksVersion}.nupkg";
      inherit hash;
    };

  wasmPackRoot = stdenv.mkDerivation {
    pname = "dotnet-wasm-tools-packs";
    version = pins.wasmPacksVersion;
    dontUnpack = true;
    nativeBuildInputs = [unzip python3 autoPatchelfHook];
    # clang/wasm-ld/binaryen/node/mono-aot-cross are prebuilt glibc binaries
    # (they bundle their own libc++).
    buildInputs = [zlib stdenv.cc.cc.lib];
    # The emscripten cache (sysroot) is huge and contains no ELF objects
    # worth patching; the .wasm/.a are not ELF either.
    dontStrip = true;
    installPhase =
      ''
        runHook preInstall
        mkdir -p $out/packs $out/library-packs
      ''
      + lib.concatStrings (lib.mapAttrsToList (id: hash: ''
          d=$out/packs/${id}/${pins.wasmPacksVersion}
          mkdir -p $d
          unzip -q ${fetchPack id hash} -d $d
          # NuGet zips drop unix permissions; the packs record them.
          python3 ${./fix-nupkg-permissions.py} $d
        '')
        pins.wasmPacks)
      + lib.concatStrings (lib.mapAttrsToList (id: hash: ''
          cp ${fetchPack id hash} $out/library-packs/${lib.toLower id}.${pins.wasmPacksVersion}.nupkg
        '')
        pins.wasmLibraryPacks)
      + ''
        runHook postInstall
      '';
    meta.description = ".NET 10 wasm-tools workload packs (incl. emscripten 3.1.56) as a workload pack root";
  };

  emsdkDir = "${wasmPackRoot}/packs/Microsoft.NET.Runtime.Emscripten.3.1.56.Sdk.linux-x64/${pins.wasmPacksVersion}/tools";
  emsdkNode = "${wasmPackRoot}/packs/Microsoft.NET.Runtime.Emscripten.3.1.56.Node.linux-x64/${pins.wasmPacksVersion}/tools/bin/node";
  emsdkCache = "${wasmPackRoot}/packs/Microsoft.NET.Runtime.Emscripten.3.1.56.Cache.linux-x64/${pins.wasmPacksVersion}/tools/emscripten/cache";

  # Sets up the .NET-shipped emscripten like the WebAssembly SDK does
  # (BrowserWasmApp.targets EmscriptenEnvVars). The cache must be writable:
  # Godot's web build compiles ports/system libs the prebuilt cache lacks.
  emsdkEnv = ''
    export DOTNET_EMSCRIPTEN_LLVM_ROOT=${emsdkDir}/bin
    export DOTNET_EMSCRIPTEN_BINARYEN_ROOT=${emsdkDir}
    export DOTNET_EMSCRIPTEN_NODE_JS=${emsdkNode}
    export EM_CACHE=$TMPDIR/emscripten-cache
    if [ ! -d "$EM_CACHE" ]; then
      cp -r --no-preserve=mode ${emsdkCache} "$EM_CACHE"
      # The prebuilt cache records the LLVM path it was built with; on a
      # mismatch emscripten wipes it and rebuilds every system library.
      echo "3.1.56|${emsdkDir}/bin" > "$EM_CACHE/sanity.txt"
    fi
    export EM_FROZEN_CACHE=0
    export PATH=${emsdkDir}/emscripten:${emsdkDir}/bin:$PATH
  '';

  # --- native desktop WebGPU (Dawn C-API boundary) -----------------------
  dawnRelease = fetchurl {inherit (pins.dawnLinux) url sha256;};

  dawnBoundary = stdenv.mkDerivation {
    pname = "godot-webgpu-dawn-boundary";
    version = "f9ac6c6";
    src = "${godotSource}/drivers/webgpu/native";
    nativeBuildInputs = [cmake];
    preConfigure = ''
      mkdir -p $TMPDIR/dawn
      tar -xzf ${dawnRelease} -C $TMPDIR/dawn --strip-components=1
      cmakeFlagsArray+=("-DDawn_DIR=$(echo $TMPDIR/dawn/lib*/cmake/Dawn)")
    '';
    cmakeBuildType = "Release";
    postInstall = ''
      mkdir -p $out/licenses
      cp ${twodogSrc}/nuget/webgpu/* $out/licenses/
    '';
  };
in {
  inherit godotSource wasmPackRoot emsdkEnv dawnBoundary;
}
