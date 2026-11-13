# 2dog × SchnozzleCat godot fork

[2dog](https://2dog.dev) (Godot as a .NET library) built against the
SchnozzleCat fork, following <https://2dog.dev/godot-forks.html>, as a
local NuGet feed.

Enable with `programs.godot4-mono-schnozzlecat.twodog.enable = true;`.
The module reuses the editor's `rev`/`hash` and Tracy flags.

```sh
dnx 2dog new MyGame --generic --web   # or: 2dog-fork new ...
cd MyGame
dotnet run --project MyGame.2dog
dotnet publish MyGame.web
```

## How it works

| piece | where |
| --- | --- |
| fork merged into 2dog's libgodot tree (`outfox/godot@2dog-4.7`), 3-way, fails on conflicts | `merge-sources.sh`, `sources.nix` (`godotSource`) |
| WebGPU third-party sources (tint, SPIRV-*, emdawnwebgpu) | pinned in `pins.nix`, prepared offline by `drivers/webgpu/dependencies.py` |
| mono editor → glue, GodotSharp/GodotTools, `Godot.NET.Sdk` nupkgs | `default.nix` `glueEditor` (common.nix editor pipeline) |
| libgodot `template_release`/`template_debug`/`editor`, linux-x64 + win-x64 (MinGW) | `default.nix` `linuxLibs`/`windowsLibs` (common.nix, `rawOutput`) |
| web static libgodot (+ threads variant), emscripten 3.1.56 | `default.nix` `mkWebLib`, toolchain from the .NET workload packs |
| native Dawn boundary (`libgodot_webgpu_dawn.so`) | `sources.nix` `dawnBoundary` (prebuilt Dawn release + CMake) |
| Windows Dawn boundary DLL + DXC (MSVC-only) | taken from 2dog's published win-x64 natives of the same godot commit |
| `dotnet pack` of 2dog (platforms, engine, integrations, CLI, templates) | `default.nix` `feed`, offline from `deps.json` |
| .NET wasm-tools workload (no `dotnet workload install` into the store SDK) | `wasmPackRoot` → `DOTNETSDK_WORKLOAD_PACK_ROOTS` |

The Steamworks runtime (`libsteam_api.so` / `steam_api64.dll`) ships next
to libgodot in the native packages. The GodotSteam module links against it.

### Versions

* 2dog packages: `4.7.2.<revision*100000 + hex(rev[0:4]) % 100000>`, e.g.
  `4.7.2.15932164`. They have to be *stable* versions (plain `dnx 2dog`
  ignores prereleases) and must differ from nuget.org's. Assembly versions
  stay at `4.7.2.159`.
* Godot.NET.Sdk/GodotSharp: `4.7.2-schnozzlecat-<rev[0:3]>.<rev[3]>`, the same
  scheme as the editor package.
* Package source mapping (`~/NuGet.Config`, jailed pi) sends `2dog*`,
  `Godot.*` and `GodotSharp*` to the local feed only.

## Not built

osx-arm64, android and iOS natives are empty stubs. They need macOS/Xcode or
the Android NDK. The MAUI/iOS host packages (`build-maui`) are not built
either.

## Updating

* **Fork rev**: set the module's `rev`/`hash`. The fork must stay mergeable
  into the pinned 2dog tree. On conflicts, merge by hand into a fork branch
  and point `rev` at it. If the fork moves to another upstream base, update
  `forkBase` in `pins.nix`.
* **2dog**: bump `twodog` and `godot2dog` in `pins.nix` (`git ls-tree <rev>
  godot`), along with `godotVersion`/`revision` from that rev's
  `Directory.Build.props`, `webgpuDeps` from
  `godot/drivers/webgpu/dependencies.json`, and the Dawn/gdunit pins from
  `scripts/webgpu.py` and `twodog.gdunit/GdUnitRuntime.props`.
* **deps.json** (NuGet lock): the union of the editor's
  `../godot4-mono-schnozzlecat/4.7/deps.json` and a restore of the merged
  tree's Godot solutions plus 2dog's packable projects. The `2dog.*` and
  `Godot*` packages, which the build produces itself, are excluded.
  Regenerate it by restoring with stub packages for those ids into an empty
  `NUGET_PACKAGES`, then run `nuget-to-json` over that folder.
