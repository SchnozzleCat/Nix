{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "sprite-illuminator";
  version = "2.1.2";

  src = pkgs.fetchurl {
    url = "https://www.codeandweb.com/download/spriteilluminator/2.1.2/SpriteIlluminator-2.1.2.deb";
    sha256 = "sha256-HTT/br/HeMw8wCeQ93VoomZn5KK58PysUkFAn9k87OM=";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.dpkg
  ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xcbutilcursor
    libGL
    glib
    gtk3
    fontconfig
    freetype
    dbus
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
  ];

  appendRunpaths = [ "${placeholder "out"}/lib/spriteilluminator" ];

  dontWrapQtApps = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
    if [ -d opt ]; then
      cp -r opt/* $out/
    fi
  '';

  meta = with pkgs.lib; {
    description = "SpriteIlluminator normal map generator";
    homepage = "https://www.codeandweb.com/spriteilluminator";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
