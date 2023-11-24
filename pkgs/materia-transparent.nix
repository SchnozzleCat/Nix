{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  sassc,
  gnome,
  gtk-engine-murrine,
  gdk-pixbuf,
  librsvg,
}:
stdenv.mkDerivation rec {
  pname = "materia-theme-transparent";
  version = "20210322";

  src = fetchFromGitHub {
    owner = "ckissane";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dHcwPTZFWO42wu1LbtGCMm2w/YHbjSUJnRKcaFllUbs=;";
  };

  nativeBuildInputs = [meson ninja sassc];

  buildInputs = [gnome.gnome-themes-extra gdk-pixbuf librsvg];

  propagatedUserEnvPkgs = [gtk-engine-murrine];

  dontBuild = true;

  mesonFlags = [
    "-Dgnome_shell_version=${lib.versions.majorMinor gnome.gnome-shell.version}"
  ];

  postInstall = ''
    rm $out/share/themes/*/COPYING
  '';

  meta = with lib; {
    description = "Materia Transparent is a Material Design theme for GNOME/GTK based desktop environments";
    homepage = "https://github.com/ckissane/materia-theme-transparent";
    license = licenses.gpl2Only;
    platforms = platforms.all;
  };
}
