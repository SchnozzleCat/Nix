# Generates the C# API bindings ("mono glue") needed to cross-compile
# mono-enabled Godot builds for Windows from Linux.
#
# Glue generation is a runtime action of a built mono editor
# (`--generate-mono-glue`), so it must be produced by running the *Linux*
# editor built from the exact same source revision that the Windows build
# will use. This matches the official recipe:
# https://github.com/godotengine/godot-build-scripts/blob/master/build-mono-glue/build.sh
#
# The output is a directory containing `GodotSharp/GodotSharp/Generated` and
# `GodotSharp/GodotSharpEditor/Generated`, which are copied into the source
# tree of the windows build (see common.nix `preConfigure`).
{
  lib,
  runCommand,
  # A (Linux) mono editor package of the same source rev as the target build.
  godot-editor,
}:
runCommand "godot-mono-glue" {
  nativeBuildInputs = [godot-editor];

  passthru = {
    inherit godot-editor;
  };

  meta = {
    description = "Generated C# API bindings (mono glue) for cross-compiling Godot";
    inherit (godot-editor.meta) license maintainers platforms;
  };
}
''
  export HOME=$(mktemp -d)

  # Must not run inside a project directory, see BindingsGenerator::
  # handle_cmdline_args upstream.
  cd "$(mktemp -d)"

  godot-mono --headless --generate-mono-glue "$out"

  test -d "$out"/GodotSharp/GodotSharp/Generated || {
    echo "glue generation did not produce GodotSharp/GodotSharp/Generated" >&2
    exit 1
  }
  test -d "$out"/GodotSharp/GodotSharpEditor/Generated || {
    echo "glue generation did not produce GodotSharp/GodotSharpEditor/Generated" >&2
    exit 1
  }
''
