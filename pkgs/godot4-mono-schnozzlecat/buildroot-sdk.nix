# Godot's official Linux toolchain: a buildroot GCC SDK with an old glibc
# sysroot (2.34) plus the X11/Wayland/ALSA/Pulse/... headers Godot's
# `use_sowrap` build needs. Binaries built with it only depend on base glibc
# libraries and run on practically every desktop distro (and in steam-run),
# exactly like the official export templates.
# https://github.com/godotengine/buildroot
# https://github.com/godotengine/build-containers/blob/main/Dockerfile.linux
#
# The SDK's own host tools (gcc, ld, pkg-config, wayland-scanner, python, ...)
# are prebuilt for /lib64/ld-linux-x86-64.so.2; they are patched to run on
# NixOS. The sysroot (the *target* glibc and libraries) is left untouched.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  patchelf,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "godot-buildroot-sdk-x86_64";
  version = "2026.05.x-1";

  src = fetchurl {
    url = "https://github.com/godotengine/buildroot/releases/download/godot-${finalAttrs.version}/x86_64-godot-linux-gnu_sdk-buildroot.tar.bz2";
    hash = "sha256-ns3mH31QD/vYz/3e8xSaAZhIAsAzyhmTXSXigpPzS7g=";
  };

  nativeBuildInputs = [patchelf];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Stripping, RPATH shrinking, shebang patching etc. would also touch the
  # target sysroot (crt objects, static libs, linker scripts). Skip them all.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    tar xjf $src -C $out --strip-components=1
    cd $out
    # Rewrites the build-time prefix in the SDK's text files (pkg-config
    # files, .la files, scripts) to the store path.
    ./relocate-sdk.sh

    # Host tools: NixOS interpreter, plus the host libstdc++/libgcc_s and
    # glibc next to the SDK's own `$ORIGIN/../lib` RPATH.
    interp=${lib.escapeShellArg stdenv.cc.bintools.dynamicLinker}
    hostLibs=${lib.makeLibraryPath [stdenv.cc.cc.lib stdenv.cc.libc]}
    find bin libexec x86_64-godot-linux-gnu/bin -type f -print0 |
      while IFS= read -r -d "" f; do
        patchelf --print-interpreter "$f" >/dev/null 2>&1 || continue
        rpath=$(patchelf --print-rpath "$f")
        patchelf --set-interpreter "$interp" --set-rpath "''${rpath:+$rpath:}$hostLibs" "$f"
      done

    runHook postInstall
  '';

  meta = {
    description = "Godot's buildroot GCC toolchain with an old-glibc sysroot for portable Linux builds";
    homepage = "https://github.com/godotengine/buildroot";
    license = lib.licenses.gpl2Plus;
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
