{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
# Prebuilt Mesa/NIR static libraries for the Direct3D 12 rendering driver,
# as distributed by godotengine for MinGW/GCC cross-compilation:
# https://github.com/godotengine/godot-nir-static
#
# The archive contains:
# - `bin/libNIR.windows.x86_64.a` — the static NIR (SPIR-V -> DXIL) library
#   that Godot links the D3D12 rendering driver against;
# - `godot-mesa/` — the Mesa headers (with pre-generated files), which
#   `drivers/d3d12/SCsub` adds to the include path and version-checks
#   against (`VERSION.info` must be >= 25.3 for Godot 4.6/4.7).
#
# This is the `x86_64-gcc` (MSVCRT, posix threads, GCC) variant, matching
# nixpkgs' `pkgsCross.mingwW64` (MinGW-w64 GCC with msvcrt CRT).
stdenvNoCC.mkDerivation {
  pname = "godot-nir-static";
  version = "25.3.1-3";

  src = fetchurl {
    url = "https://github.com/godotengine/godot-nir-static/releases/download/25.3.1-3/godot-nir-static-x86_64-gcc-release.zip";
    hash = "sha256-3JipYqyQYTpPzPKQgtNLEvy5e/OBlRcSW8PRyG7TGvw=";
  };

  nativeBuildInputs = [unzip];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    # The "<mesa_libs>-x86_64-gcc" suffix matches what
    # platform/windows/detect.py looks for, and its unsuffixed fallback is
    # what drivers/d3d12/SCsub resolves to when building without MSVC/LLVM.
    mkdir -p "$out"/mesa-x86_64-gcc
    cp -r bin godot-mesa "$out"/mesa-x86_64-gcc/
    runHook postInstall
  '';

  meta = {
    description = "Prebuilt Mesa/NIR static libraries for Godot's D3D12 driver";
    homepage = "https://github.com/godotengine/godot-nir-static";
    license = with lib.licenses; [mit];
    platforms = ["x86_64-linux"];
  };
}
