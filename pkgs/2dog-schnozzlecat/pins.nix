# Pinned inputs of the 2dog build of the SchnozzleCat godot fork.
#
# 2dog (https://2dog.dev) hosts libgodot inside .NET. It ships its own Godot
# fork (outfox/godot, branch `2dog-<line>`) carrying the libgodot changes; a
# custom engine fork has to be merged INTO that tree, see
# https://2dog.dev/godot-forks.html. Instead of maintaining a merged branch,
# the merge happens at build time (./merge-sources.sh): the fork's changes
# (forkBase..fork.rev) are applied onto the 2dog godot tree, 3-way, failing
# on conflicts.
#
# Bumping:
#   - fork:   set `fork.rev`/`fork.hash` (or the home-manager module's
#             rev/hash). `forkBase` must stay the upstream commit the fork
#             branched from (`git merge-base`), normally the `-stable` tag.
#   - 2dog:   bump `twodog.rev` (2dog repo, release branch `<line>`) and
#             `godot2dog.rev` to its `godot` submodule commit
#             (`git ls-tree <rev> godot`), plus the version fields from
#             that rev's Directory.Build.props. Regenerate deps.json (see
#             default.nix `passthru.fetch-deps`).
{
  # Upstream Godot commit the fork branched from (4.7-stable).
  forkBase = {
    owner = "godotengine";
    repo = "godot";
    rev = "5b4e0cb0fd279832bbdd69fed5354d4e5ad26f88";
    hash = "sha256-DBVxc5ScaFJHc5WMMCQBn51ZTZdggavCmqRbaxL9gi0=";
  };

  # Default fork commit (overridable from the home-manager module, which
  # forwards programs.godot4-mono-schnozzlecat.{rev,hash}).
  fork = {
    owner = "SchnozzleCat";
    repo = "godot";
    rev = "7da4fae2b0456e15ec8b606396735c9a000f5d16";
    hash = "sha256-gE6s+TLi4i0THXpL5xXNdqvjA2PlYQPtsUPnj+L0u8o=";
  };

  # 2dog's libgodot godot tree: the `godot` submodule of `twodog.rev`
  # (outfox/godot branch 2dog-4.7).
  godot2dog = {
    owner = "outfox";
    repo = "godot";
    rev = "7606ec3bdc344067f6e55916cdd203324c011832";
    hash = "sha256-oyPeqoz9BYXAs/YLlgNxkb1fYEKGaUVj7Si2Wiczwdg=";
  };

  # 2dog itself (outfox/2dog, release branch 4.7).
  twodog = {
    owner = "outfox";
    repo = "2dog";
    rev = "621a48ab57acf9e60e50083e43dc6f17e23314b6";
    hash = "sha256-SuauDae0VcSQT71HQ2tnX8eMw27ZGkE+O2Taa/5vXCI=";
    # From that rev's Directory.Build.props.
    godotVersion = "4.7.2"; # <GodotVersion>, == godot/version.py
    revision = 159; # <TwoDogRevision> == <NativesRevision>
  };

  # WebGPU third-party sources (drivers/webgpu/dependencies.json of the 2dog
  # godot tree); dependencies.py normally downloads them at build time.
  webgpuDeps = {
    tint = {
      url = "https://codeload.github.com/google/dawn/tar.gz/db49a5496374b1f7284e0b9c8f2964c01d4bb20a";
      sha256 = "923405c05f59343b87533cba2896123c6504f79e6404b581a03d6bddfffe3010";
    };
    spirv-tools = {
      url = "https://codeload.github.com/KhronosGroup/SPIRV-Tools/tar.gz/3605cce5b11f6a085107fd400f1721cd2a59c49e";
      sha256 = "693f7a9a00d599b99733428970fd8d897e3367d1d2e33e0ea54e4f15226db90e";
    };
    spirv-headers-webgpu = {
      url = "https://codeload.github.com/KhronosGroup/SPIRV-Headers/tar.gz/ad9184e76a66b1001c29db9b0a3e87f646c64de0";
      sha256 = "b5b7eba62453eb8c6f6a5fbf7155b71cde693bafe9cd5f03b79ed8c714816afe";
    };
    emdawnwebgpu = {
      url = "https://github.com/google/dawn/releases/download/v20251002.162335/emdawnwebgpu_pkg-v20251002.162335.zip";
      sha256 = "5c8c3f0d1f115ad476068dbd65a85347103717138bc686ae08de9f98fcc93d9a";
    };
  };

  # Prebuilt Dawn release (scripts/webgpu.py DAWN_ARCHIVES) for the native
  # desktop WebGPU boundary library (libgodot_webgpu_dawn.so).
  dawnLinux = {
    url = "https://github.com/google/dawn/releases/download/v20261014.133826/Dawn-f9ac6c61ff0a88ddec67db7f2d0455b4125ab69d-ubuntu-latest-Release.tar.gz";
    sha256 = "8685f909d0cbbf4256e3907ba72c921dbcda8687b282194740e73af348edb511";
  };

  # The Windows Dawn boundary DLL (+ DXC) only builds with MSVC (Dawn's
  # Windows release is MSVC-only), so it is taken from 2dog's own published
  # win-x64 natives built from the same godot2dog commit (the nuspec's
  # repository commit is 7606ec3...). The boundary DLL only depends on
  # Dawn and the Windows runtime, never on engine code, so it is identical
  # for the fork.
  twodogWinNatives = {
    url = "https://api.nuget.org/v3-flatcontainer/2dog.win-x64.release/4.7.2.162/2dog.win-x64.release.4.7.2.162.nupkg";
    hash = "sha256-czzjKnDCNylKN0IrZFSrXJCxnHIOXrXCVsoof9HLGRM=";
  };

  # GdUnit runtime bundled into 2dog.gdunit (twodog.gdunit/GdUnitRuntime.props).
  gdunit = {
    version = "6.2.2";
    url = "https://github.com/godot-gdunit-labs/gdUnit4/archive/refs/tags/v6.2.2.zip";
    sha256 = "ddb44730ffb9cd77fd70d283753450759b00c5016143d7572bf63625f64d5433";
  };

  # .NET 10 browser-wasm workload packs ("wasm-tools", workload manifest
  # 10.0.114 of the 10.0.1xx band) incl. the Emscripten 3.1.56 the browser
  # runtime pack was built with. 2dog's web libgodot.a MUST be compiled with
  # this exact emscripten (it is linked into dotnet.native.wasm). Version
  # 10.0.14 matches the nixpkgs .NET 10 runtime.
  wasmPacksVersion = "10.0.14";
  wasmPacks = {
    "Microsoft.NET.Runtime.MonoAOTCompiler.Task" = "sha256-EO+8+xkbixsrgUHfLmdsjxgvpaoC15gcB7hlrZl1YnU=";
    "Microsoft.NET.Runtime.MonoTargets.Sdk" = "sha256-lSL8jCOsVZLzigeI0y+V42XvrFzJI7xxLhL2lE612Fk=";
    "Microsoft.NET.Runtime.WebAssembly.Sdk" = "sha256-QZTB9J7c0aBt/WmGWmi4FJtk1hQbRoWBRjOhd8Xe2Pk=";
    "Microsoft.NETCore.App.Runtime.Mono.browser-wasm" = "sha256-hp7CV8VJx9N2e1ZJFGtwdc5FqUw0w2MY5xqCLr2qDCM=";
    "Microsoft.NETCore.App.Runtime.AOT.linux-x64.Cross.browser-wasm" = "sha256-eG6/PnLT6lUnDeYXF21GlzDm+temRFK3auOoHOsI3ww=";
    "Microsoft.NET.Runtime.Emscripten.3.1.56.Sdk.linux-x64" = "sha256-3gBw8wIdKMrmm74DoD9SzqXeEW3IxfFSSD9QQJRqhfA=";
    "Microsoft.NET.Runtime.Emscripten.3.1.56.Node.linux-x64" = "sha256-MnIiRjfFpBJGOFgq+iy3hvRF4w2nUSKsK+IjO7HrmQY=";
    "Microsoft.NET.Runtime.Emscripten.3.1.56.Cache.linux-x64" = "sha256-75+kEB80omJEZJJ2y+bVkJf0mjyIkdQCWVkditey6DI=";
  };
  # library-kind workload pack (lands in <root>/library-packs as a nupkg).
  wasmLibraryPacks = {
    "Microsoft.NET.Sdk.WebAssembly.Pack" = "sha256-Nk+UOdbUm0t2f948USY7ZKaNE75tB9KKiD1WKDwiBl0=";
  };
}
