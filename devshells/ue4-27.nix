# Development environment for building Unreal Engine 4.27 from source.
#
# Epic's UnrealBuildTool and the engine's bundled binaries hard-code FHS-style
# paths (/usr/lib, ...), so the actual build/run happens inside a
# `buildFHSEnv` bubblewrap sandbox: run `ue4-27` to enter it.
#
# NOTE: github.com/EpicGames/UnrealEngine is only visible to GitHub accounts
# that signed up at unrealengine.com and linked them (EULA acceptance); the
# git clone therefore uses your normal GitHub credentials.
{
  pkgs,
  # Tag/branch on github:EpicGames/UnrealEngine ("4.27.2" -> tag 4.27.2-release).
  version ? "4.27.2",
  # UBT 4.27 expects clang 10-16; too-new majors often break on removed flags.
  # Old clangs are removed from modern nixpkgs as `throw` aliases (and some are
  # gone entirely), so probe with `?` + tryEval: `?` handles missing attrs
  # (which tryEval does NOT catch here), tryEval handles the throw aliases.
  clangPkg ? let
    candidates = [
      "clang_15"
      "clang_14"
      "clang_13"
      "clang_12"
      "clang_16"
    ];
    first =
      pkgs.lib.findFirst
      (n: (pkgs ? "${n}") && (builtins.tryEval pkgs."${n}").success)
      null
      candidates;
  in
    if first != null then pkgs."${first}" else pkgs.clang,
}: let
  # Packages the engine's third-party build scripts (Setup.sh targets) and the
  # compiled editor binaries expect to find at their standard FHS locations.
  fhsPkgs = p: (with p; [
    # Toolchain
    clangPkg
    gcc
    lld
    lldb
    # Build glue
    python3
    perl
    rsync
    unzip
    zip
    gnutar
    file
    which
    pkg-config
    curl
    wget
    cacert
    openssl
    zlib
    icu # .NET runtime localization
    # Graphics
    libGL
    vulkan-loader
    vulkan-headers
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libxscrnsaver
    libxxf86vm
    libxcb
    libxkbcommon
    wayland
    wayland-protocols
    SDL2
    # Audio
    alsa-lib
    libpulseaudio
    libjack2
    # Desktop/system
    dbus
    glib
    gtk3
    fontconfig
    freetype
    harfbuzz
    udev
    util-linux # libuuid
    libcap
    ncurses
    xdg-utils
    xdg-user-dirs
  ]);

  # Enter with `ue4-27` for an FHS bash (setup, GenerateProjectFiles, make,
  # running the built editor).
  ue4Env = pkgs.buildFHSEnv {
    name = "ue4-27";
    runScript = "bash";
    targetPkgs = fhsPkgs;
    profile = ''
      # The .NET runtime Setup.sh pulls in for UnrealBuildTool wants ICU at
      # versions modern NixOS doesn't ship; invariant mode avoids that (and
      # libssl mismatches) entirely.
      export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
    '';
  };

  # One-shot: git-clone the source if needed, then Setup.sh,
  # GenerateProjectFiles.sh, and the default make targets. Run from the
  # UnrealEngine root (an empty directory works for cloning into).
  ue4Setup = pkgs.writeShellScriptBin "ue4-setup" ''
    set -euo pipefail
    if [ ! -d ./Engine ]; then
      if [ -n "$(ls -A .)" ]; then
        echo "ue4-setup: current directory is not an UnrealEngine root and not empty." >&2
        echo "  Run from an UnrealEngine checkout, or an empty directory to clone the source into." >&2
        exit 1
      fi
      git clone --depth 1 --branch ${version}-release \
        https://github.com/EpicGames/UnrealEngine.git .
    fi
    exec ${ue4Env}/bin/ue4-27 -c '
      set -e
      # Setup.sh fetches the third-party binaries from the Epic CDN. The
      # excludes skip platform toolchains Linux cannot use; drop them if you
      # want the full set.
      ./Setup.sh --exclude=Android --exclude=Mac
      ./GenerateProjectFiles.sh
      make -j"$(nproc)"
    '
  '';
  # Build the editor target (4.27: UE4Editor). Not part of `make`'s default
  # target, and not in the generated Makefile at all. Run from the
  # UnrealEngine root. Builds ShaderCompileWorker first: the editor needs it
  # as soon as it submits shader compile jobs.
  ue4BuildEditor = pkgs.writeShellScriptBin "ue4-build-editor" ''
    set -euo pipefail
    if [ ! -d ./Engine ]; then
      echo "ue4-build-editor: not an UnrealEngine root; run from the checkout directory" >&2
      exit 1
    fi
    exec ${ue4Env}/bin/ue4-27 -c '
      Engine/Build/BatchFiles/Linux/Build.sh ShaderCompileWorker Linux Development
      Engine/Build/BatchFiles/Linux/Build.sh UE4Editor Linux Development
    '
  '';
  # Export a clangd compile_commands.json for a project (run from the
  # UnrealEngine root): ue4-compile-commands /abs/path/to/Project.uproject
  # Regenerate after adding/removing source files.
  ue4GenCompileCommands = pkgs.writeShellScriptBin "ue4-compile-commands" ''
    set -euo pipefail
    if [ ! -d ./Engine ]; then
      echo "ue4-compile-commands: run from the UnrealEngine root" >&2
      exit 1
    fi
    if [ "$#" -ne 1 ]; then
      echo "usage: ue4-compile-commands /abs/path/to/Project.uproject" >&2
      exit 1
    fi
    arg=$(readlink -f "$1")
    case "$arg" in
      *.uproject)
        uproject=$arg
        ;;
      *)
        uproject=$(find "$arg" -maxdepth 1 -name '*.uproject' -print -quit)
        if [ -z "$uproject" ]; then
          echo "no .uproject in '$arg'; pass the project file explicitly" >&2
          exit 1
        fi
        echo "using project: $uproject"
        ;;
    esac
    projdir=$(dirname "$uproject")
    # 4.27 on Linux runs UBT through the bundled Mono via Build.sh. Invoke
    # UBT *through Build.sh* (it passes args straight through) so the
    # environment matches the editor build that provably found clang;
    # sourcing SetupMono.sh + calling mono directly misses whatever else
    # Build.sh sets up and fails with "Clang must be installed".
    # The editor target for a project is <ProjectName>Editor on UE4.
    target="$(basename "$uproject" .uproject)Editor"
    ${ue4Env}/bin/ue4-27 -c "
      Engine/Build/BatchFiles/Linux/Build.sh \"$target\" Linux Development \"$uproject\" -mode=GenerateClangDatabase
    "
    db=$(find "$projdir" -name compile_commands.json 2>/dev/null | head -1)
    if [ -z "$db" ]; then
      db=$(find "$(pwd)/Engine/Intermediate" -name compile_commands.json 2>/dev/null | head -1)
    fi
    if [ -z "$db" ]; then
      # Fallback: the VSCode project generator writes .vscode/compileCommands_<Project>.json
      ${ue4Env}/bin/ue4-27 -c "
        source Engine/Build/BatchFiles/Linux/SetupMono.sh $(pwd)/Engine/Build/BatchFiles/Linux
        mono Engine/Binaries/DotNET/UnrealBuildTool.exe -projectfiles -project=\"$uproject\" -game -engine -vscodeformat
      "
      db=$(find "$projdir/.vscode" -maxdepth 1 -name 'compileCommands_*.json' 2>/dev/null | head -1)
    fi
    if [ -n "$db" ]; then
      ln -sf "$db" "$projdir/compile_commands.json"
      echo "clangd db: $db -> $projdir/compile_commands.json"
    else
      echo "ue4-compile-commands: no compile database produced. Do it via the editor instead:" >&2
      echo "  Edit > Editor Preferences > Source Code > Source Code Editor = Visual Studio Code" >&2
      echo "  File > Refresh Visual Studio Code Project" >&2
      echo "  then: ln -s .vscode/compileCommands_<Project>.json compile_commands.json" >&2
      exit 1
    fi
  '';
in
  pkgs.mkShell {
    name = "ue4-27-devshell";
    packages = [
      ue4Env
      ue4Setup
      ue4BuildEditor
      ue4GenCompileCommands
      pkgs.git
    ];
    shellHook = ''
      echo "ue4-27 dev shell (all commands operate on the current directory):"
      echo "  ue4-setup           git-clone the source + Setup.sh + GenerateProjectFiles.sh + program targets"
      echo "  ue4-build-editor    build ShaderCompileWorker + the editor (UE4Editor target)"
      echo "  ue4-compile-commands <uproject>  export a clangd compile_commands.json for a project"
      echo "  ue4-27              open the FHS env directly (e.g. to rebuild or run the editor)"
    '';
  }
