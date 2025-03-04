{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  autoPatchelfHook,
  installShellFiles,
  scons,
  python3,
  mkNugetDeps,
  vulkan-loader,
  libGL,
  libX11,
  libXcursor,
  libXinerama,
  libXext,
  libXrandr,
  libXrender,
  libXi,
  libXfixes,
  libxkbcommon,
  alsa-lib,
  libpulseaudio,
  dbus,
  speechd,
  fontconfig,
  udev,
  wayland-scanner,
  wayland,
  libdecor,
  withPlatform ? "linuxbsd",
  withTarget ? "editor",
  withPrecision ? "single",
  withPulseaudio ? true,
  withDbus ? true,
  withSpeechd ? true,
  withFontconfig ? true,
  withUdev ? true,
  deps ? ./deps.nix,
  mono,
  callPackage,
  dotnet-sdk_8,
  dotnet-runtime_8,
  makeWrapper,
  msbuild,
  withCommitHash ? "5319cbcf54e801af34d24bf682af75c8ee9a17a4",
  withHash ? "sha256-JvEKsaG664gcjHjlR+GRJGctj3lJZIvVQ0OBNWiZLfA=",
  withVersion ? "4.3",
  withPName ? "godot4-mono-schnozzlecat",
}:
assert lib.asserts.assertOneOf "withPrecision" withPrecision ["single" "double"];
  stdenv.mkDerivation rec {
    pname = withPName;
    version = withVersion;
    commitHash = withCommitHash;

    src = fetchFromGitHub {
      owner = "SchnozzleCat";
      repo = "godot";
      rev = commitHash;
      hash = withHash;
      fetchSubmodules = true;
    };

    keepNugetConfig = deps == null;

    nativeBuildInputs = [
      pkg-config
      autoPatchelfHook
      installShellFiles
      python3
      speechd
      wayland-scanner
      makeWrapper
      mono
      dotnet-sdk_8
      dotnet-runtime_8
    ];

    buildInputs =
      [
        scons
      ]
      ++ lib.optional (deps != null)
      (mkNugetDeps {
        name = "deps";
        nugetDeps = import deps;
      });

    runtimeDependencies =
      [
        vulkan-loader
        libGL
        libX11
        libXcursor
        libXinerama
        speechd
        libXext
        libXrandr
        libXrender
        libXi
        libXfixes
        libxkbcommon
        alsa-lib
        mono
        wayland-scanner
        wayland
        libdecor
        dotnet-sdk_8
        dotnet-runtime_8
      ]
      ++ lib.optional withPulseaudio libpulseaudio
      ++ lib.optional withDbus dbus
      ++ lib.optional withDbus dbus.lib
      ++ lib.optional withSpeechd speechd
      ++ lib.optional withFontconfig fontconfig
      ++ lib.optional withFontconfig fontconfig.lib
      ++ lib.optional withUdev udev;

    enableParallelBuilding = true;

    # Set the build name which is part of the version. In official downloads, this
    # is set to 'official'. When not specified explicitly, it is set to
    # 'custom_build'. Other platforms packaging Godot (Gentoo, Arch, Flatpack
    # etc.) usually set this to their name as well.
    #
    # See also 'methods.py' in the Godot repo and 'build' in
    # https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
    BUILD_NAME = "nixpkgs";

    # Required for the commit hash to be included in the version number.
    #
    # `methods.py` reads the commit hash from `.git/HEAD` and manually follows
    # refs. Since we just write the hash directly, there is no need to emulate any
    # other parts of the .git directory.
    #
    # See also 'hash' in
    # https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
    preConfigure = ''
      mkdir -p .git
      echo ${commitHash} > .git/HEAD
    '';

    outputs = ["out" "man"];

    postConfigure = ''
      echo "Setting up buildhome."
      mkdir buildhome
      export HOME="$PWD"/buildhome
    '';

    buildPhase = ''
      export GODOT_VERSION_STATUS=SchnozzleCat-${builtins.substring 0 10 commitHash}
      echo "Exporting NuGet with version $GODOT_VERSION_STATUS"

      echo "Starting Build"
      scons p=${withPlatform} target=${withTarget} precision=${withPrecision} module_mono_enabled=yes module_text_server_fb_enabled=yes mono_glue=no

      echo "Generating Glue"
      if [[ ${withPrecision} == *double* ]]; then
          bin/godot.${withPlatform}.${withTarget}.${withPrecision}.x86_64.mono --headless --generate-mono-glue modules/mono/glue
      else
          bin/godot.${withPlatform}.${withTarget}.x86_64.mono --headless --generate-mono-glue modules/mono/glue
      fi

      echo "Building Assemblies"
      scons p=${withPlatform} target=${withTarget} precision=${withPrecision} module_mono_enabled=yes module_text_server_fb_enabled=yes mono_glue=yes

      echo "Building C#/.NET Assemblies"
      python modules/mono/build_scripts/build_assemblies.py --godot-output-dir bin --precision=${withPrecision} --push-nupkgs-local $GODOT_VERSION_STATUS

      echo "Building Export Templates"
      scons platform=linuxbsd target=template_release arch=x86_64 module_mono_enabled=yes
      scons platform=linuxbsd target=template_debug arch=x86_64 module_mono_enabled=yes
    '';

    installPhase = ''
      mkdir -p "$out/bin"
      cp bin/godot.${withPlatform}.${withTarget}.x86_64.mono $out/bin/godot4-mono-schnozzlecat
      cp -r bin/GodotSharp/ $out/bin/GodotSharp
      cp -r $GODOT_VERSION_STATUS $out/$GODOT_VERSION_STATUS
      mkdir -p $out/godot-export-templates
      cp bin/godot.${withPlatform}.template_debug.x86_64.mono $out/godot-export-templates/linux_release.x86_64
      cp bin/godot.${withPlatform}.template_release.x86_64.mono $out/godot-export-templates/linux_debug.x86_64
      installManPage misc/dist/linux/godot.6

      mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
      cp misc/dist/linux/org.godotengine.Godot.desktop "$out/share/applications/org.godotengine.Godot4-Mono-SchnozzleCat.desktop"
      substituteInPlace "$out/share/applications/org.godotengine.Godot4-Mono-SchnozzleCat.desktop" \
        --replace "Exec=godot" "Exec=$out/bin/godot4-mono-schnozzlecat" \
        --replace "Godot Engine" "SchnozzleCat Godot Engine ${version} (Mono, $(echo "${withPrecision}" | sed 's/.*/\u&/') Precision)"
      cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
      cp icon.png "$out/share/icons/godot.png"
    '';

    meta = with lib; {
      homepage = "https://godotengine.org";
      description = "Free and Open Source 2D and 3D game engine";
      license = licenses.mit;
      platforms = ["i686-linux" "x86_64-linux" "aarch64-linux"];
      maintainers = with maintainers; [ilikefrogs101];
      mainProgram = "godot4-mono";
    };

    passthru = {
      make-deps = callPackage ./make-deps.nix {};
    };
  }
