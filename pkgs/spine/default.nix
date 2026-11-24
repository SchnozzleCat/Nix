# Spine (https://esotericsoftware.com), 2D skeletal animation editor.
#
# This packages the Linux *launcher* (Spine.tar.gz). The launcher
# downloads the actual Spine editor (trial, or full once you log in with a
# license) into the user's home at runtime, and those downloaded binaries are
# generic Linux ones, so everything runs inside a buildFHSEnv.
#
# NOTE: the launcher zip comes from the local store (requireFile); add it with
#   nix-store --add-fixed sha256 /path/to/Spine.zip
{
  lib,
  stdenvNoCC,
  fetchurl,
  requireFile,
  buildFHSEnv,
  writeShellScript,
  makeDesktopItem,
}: let
  # The tarball ships no icon; use the site's apple-touch-icon.
  icon = fetchurl {
    url = "https://en.esotericsoftware.com/apple-touch-icon-180x180.png";
    hash = "sha256-zSTJK255wVf3kHW8yR2dBMfqglwRmKOHwo8NH7RFNQY=";
  };

  desktopItem = makeDesktopItem {
    name = "spine";
    desktopName = "Spine";
    genericName = "2D Skeletal Animation";
    comment = "2D skeletal animation editor";
    exec = "spine %F";
    icon = "spine";
    categories = ["Graphics" "2DGraphics" "Development"];
  };

  launcher = stdenvNoCC.mkDerivation {
    pname = "spine-launcher";
    version = "unstable-2026-09-08";

    # Pulled from the local store; add it with
    #   nix-store --add-fixed sha256 /path/to/Spine.zip
    # then set `hash` to the file's sha256 (`nix hash file --sri <zip>`).
    src = requireFile {
      name = "Spine.tar.gz";
      hash = "sha256-/wgL966eYkXJ0Ckm5819bwWB6TPvLR9ZwlX22pW2Bx0=";
      message = ''
        Add the Spine zip to the store with:
          nix-store --add-fixed sha256 /path/to/Spine.tar.gz
          nix hash file --sri /path/to/Spine.tar.gz
      '';
    };

    dontBuild = true;
    dontFixup = true; # JVM is run inside the FHS env, not patched

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/spine
      cp -r . $out/share/spine
      runHook postInstall
    '';
  };
in
  buildFHSEnv {
    name = "spine";
    # The launcher writes next to itself (.shared, updates), so run it from a
    # writable per-store-path copy instead of the read-only store.
    runScript = writeShellScript "spine-run" ''
      dir="''${XDG_DATA_HOME:-$HOME/.local/share}/spine-launcher/$(basename ${launcher})"
      if [ ! -e "$dir/.copied" ]; then
        rm -rf "$dir"
        mkdir -p "$dir"
        cp -rL --no-preserve=ownership ${launcher}/share/spine/. "$dir"
        chmod -R u+w "$dir"
        touch "$dir/.copied"
      fi
      exec "$dir/Spine.sh" "$@"
    '';
    targetPkgs = pkgs:
      with pkgs; [
        # LWJGL 2 shells out to the `xrandr` binary to enumerate display
        # modes; without it: "Unable to create the OpenGL display ...
        # libxrandr is required" (the library alone is not enough).
        xrandr
        mesa-demos # glxinfo, for debugging GL inside the env
        zlib
        freetype
        fontconfig
        alsa-lib
        libGL
        libGLU
        libxkbcommon
        gtk3
        glib
        stdenv.cc.cc.lib
        libx11
        libxext
        libxrender
        libxtst
        libxi
        libxrandr
        libxcursor
        libxxf86vm
        libxinerama
        libxfixes
        libxcb
        libxscrnsaver
        libdrm
        mesa
        wayland
        curl
        openssl
      ];
    extraInstallCommands = ''
      install -Dm644 ${desktopItem}/share/applications/spine.desktop \
        $out/share/applications/spine.desktop
      install -Dm644 ${icon} $out/share/pixmaps/spine.png
    '';

    meta = {
      description = "2D skeletal animation editor (launcher; trial unless licensed)";
      homepage = "https://esotericsoftware.com";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "spine";
    };
  }
