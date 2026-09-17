# Godot (schnozzlecat fork) — Windows cross-compilation

Custom Godot editor + export templates for Windows, built entirely from Linux
using MinGW-w64, following the official cross-compilation recipe
(https://github.com/godotengine/godot-build-scripts).

## Packages

- `.#godot-custom-windows-editor` — mono Windows editor (`godot.windows.editor.x86_64.mono.exe`
  + `.console.exe` + `GodotSharp/` data dir + `steam_api64.dll`). Copy the
  directory to a Windows machine to use it there.
- `.#godot-custom-windows-template` — mono Windows release template
  (`windows_release_x86_64.exe`/`..._console.exe` under
  `share/godot/export_templates/4.7.mono/`, plus `steam_api64.dll`).
- `.#godot-custom-windows-template-debug` — mono Windows debug template.
- `.#godot-custom-windows` — classical (non-mono) Windows editor, useful for
  testing the cross toolchain without the .NET overhead.

The home-manager module `programs.godot4-mono-schnozzlecat` automatically
installs the Windows templates next to the Linux ones in
`~/.local/share/godot/export_templates/4.7.schnozzlecat-<rev>.mono/`, so
`godot --export-release "Windows Desktop" out.exe` works from Linux (needs
the corresponding export presets in the game project).

Set `programs.godot4-mono-schnozzlecat.installWindowsEditor = true;` to also
place the Windows editor under `~/.local/share/godot/windows-editor`.

## How it works

Cross-compiling a *mono-enabled* Godot for Windows requires two stages,
because glue generation is a runtime action of a built editor binary:

1. **Glue generation (Linux)**: `pkgs/godot4-mono-schnozzlecat/mono-glue.nix`
   runs the Linux mono editor with `--generate-mono-glue`, producing the
   generated C# API bindings (`GodotSharp/{GodotSharp,GodotSharpEditor}/Generated`).
2. **Windows build (MinGW)**: `common.nix` with `withPlatform = "windows"`
   evaluated through `pkgs.pkgsCross.mingwW64.callPackage`. The generated
   bindings are copied into the source tree, the engine is built with
   `scons platform=windows arch=x86_64 use_mingw=yes module_mono_enabled=yes`,
   and `build_assemblies.py --godot-platform=windows` produces the C#
   assemblies (see
   https://github.com/godotengine/godot-build-scripts/blob/master/build-windows/build.sh).

Notable build options for Windows:
- All third-party libraries are built-in (the "disable builtins" patch only
  applies to the linuxbsd build).
- D3D12 is enabled using the prebuilt Mesa/NIR static libraries
  (`godot-nir-static-x86_64-gcc-release.zip` from
  https://github.com/godotengine/godot-nir-static, packaged in
  `d3d12-deps.nix` — the `x86_64-gcc`/MSVCRT variant matching
  `pkgsCross.mingwW64`).
- `lto=none`, Vulkan + OpenGL + D3D12 rendering drivers.
- AccessKit runs in dynamic mode (no MSVC SDK needed).

The build ships **without the Agility SDK** (`agility_sdk_path` unset):
D3D12 then uses the OS-provided D3D12 runtime, which requires a reasonably
up-to-date Windows 10/11. For maximum compatibility with older Windows
installs you can vendor the Agility SDK NuGet package
(`Microsoft.Direct3D.D3D12`) and pass `agility_sdk_path` to scons — but then
`D3D12Core.dll`/`d3d12SDKLayers.dll` must be shipped next to exported games.
Without it, nothing extra needs to be shipped for D3D12.

## Gotchas

- The Steamworks SDK (`steamworks_sdk_164.zip`) must be in the store, same as
  the Linux build (`nix-store --add-fixed sha256 steamworks_sdk_164.zip`).
  The Mesa/NIR D3D12 deps are a plain fetchurl, no requireFile needed.
- nixpkgs' mingw GCC uses the "mcf" threading model; Godot's posix-threads
  check only rejects the *win32* model, so it passes. `std::thread` works via
  mcfgthreads.
- `x86_64-w64-mingw32-gcc-ar`/`gcc-ranlib`/`gcc-nm` are shimmed to the cross
  binutils tools in `preConfigure` (Godot's SCons looks for them and would
  otherwise pick up the native Linux ones, which cannot handle PE objects).
- Debug symbols are not split out (`separateDebugInfo`) for Windows binaries.
- If the offline nuget restore complains about missing `win-x64` packages,
  regenerate `deps.json` via the package's `fetch-deps` passthru
  (`nix build .#godot-custom.fetch-deps` … run the resulting script).

## Exporting a game to Windows from Linux

```bash
godot --headless --export-release "Windows Desktop" ../builds/windows/Game.exe
```

The C# side needs no changes — assemblies are platform-neutral IL. The export
will pick up the Windows templates installed by the home-manager module.
For Steam builds on Windows, ship `steam_api64.dll` (from the template
directory) next to the exported game.
