{
  lib,
  stdenv,
  fetchzip,
  fetchurl,
  buildFHSEnv,
  makeDesktopItem,
}: let
  pname = "inky";
  version = "0.14.1";
  description = "An editor for the ink interactive narrative markup language";

  desktopItem = let
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/inkle/inky/${version}/resources/Icon1024.png";
      hash = "sha256-82+s7MZ8a/GGPeNVZMlbC7n1IVpgqSO/xPYrtXaEIOs=";
    };
  in
    makeDesktopItem {
      name = "Inky";
      exec = "inky";
      icon = icon;
      desktopName = "Inky";
      comment = description;
      categories = ["Development" "IDE"];
    };

  inky = let
    src = fetchzip {
      url = "https://github.com/inkle/inky/releases/download/${version}/Inky_linux.zip";
      hash = "sha256-WK63bmW6n/hsrjhBzDAi1EjxPiP2TxtuaxAIa84TAsk=";
    };
  in
    stdenv.mkDerivation {
      inherit pname version src;

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/opt/inky

        chmod 755 Inky
        mv ./* $out/opt/inky/
        ln -s $out/opt/inky/Inky $out/bin/Inky

        runHook postInstall
      '';
    };
in
  buildFHSEnv {
    inherit pname version;

    targetPkgs = pkgs:
      with pkgs; [
        inky
        # for inky itself
        udev
        # for the ink compiler
        icu
        zlib
        # for Electron
        alsa-lib
        atk
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        gtk3
        libuuid
        nspr
        nss
        pango
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
      ];

    runScript = "Inky $*";

    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      ln -s ${desktopItem}/share/applications/* "$out/share/applications"
    '';

    meta = {
      inherit description;
      longDescription = ''
        Inky is an editor for ink, inkle's markup language for writing interactive narrative in games, as used in "80 Days".
        It's an IDE (integrated development environment), because it gives you a single app that lets you play in the editor as you write, and fix any bugs in your code.
      '';
      mainProgram = "inky";
      homepage = "https://github.com/inkle/inky";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
    };
  }
