---
name: pi-jail-devshell
description: Create a Nix flake devshell containing a specialized bwrap-jailed pi coding agent (makeJailedPi) whose package set includes exactly the tools a project needs (node, python, rust, go, ...). Use when a project needs a pi jail, or when the default jailed pi lacks a runtime/toolchain the task requires.
---

# Pi-Jail Devshell

How to give the jailed pi agent the language toolchains and project-specific
tools it needs by wrapping it in a Nix flake devshell.

## Background

The default `pi` on this machine is the bwrap jail built by `makeJailedPi`
(source of truth: `~/.nixos/lib/jailed-pi.nix`, exported as
`pkgs.makeJailedPi` via the additions overlay and as
`outputs.lib.makeJailedPi pkgs {...}` from the `~/.nixos` flake). The jail
clears the environment and only bind-mounts the store paths in its own
runtime closure, so the ONLY tools pi can reach are the ones in that
closure. The default package set (`commonPkgs`) covers general-purpose dev:
bash/coreutils/grep/find, git + jujutsu, just, curl/wget/jq, ripgrep/fd,
archives, diff/patch, podman + docker clients, icu/openssl/libstdc++ runtime
libs, combined .NET SDKs (10/9/8, with `DOTNET_ROOT` injected), and the full
Godot 4 mono build environment.

Anything else (node, python, rust, go, jdk, ...) must be added per-project
via `extraPkgs` in a flake devshell.

## Quick start: external flake devshell

For a project repo, add a devshell that re-exports a specialized jail:

```nix
{
  inputs.schnozzlecat = {
    url = "github:SchnozzleCat/Nix";
    # Only the flake lib is needed; avoid a redundant system rebuild
    # if you pin nixpkgs yourself.
  };

  outputs = {
    self,
    nixpkgs,
    schnozzlecat,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        # `pi` inside `nix develop` runs the DEFAULT jail package set
        (schnozzlecat.lib.makeJailedPi pkgs {})
      ];
    };
  };
}
```

Or with project-specific tooling:

```nix
devShells.${system}.default = pkgs.mkShell {
  packages = [
    (schnozzlecat.lib.makeJailedPi pkgs {
      extraPkgs = with pkgs; [
        nodejs_22
        pnpm
        python312
        rustc
        cargo
      ];
    })
  ];
};
```

`nix develop`, then run `pi`. The jail closes over pi (+ extensions),
`commonPkgs`, and every `extraPkgs` entry.

If the host's overlay-applied `pkgs` is already in scope (e.g. inside the
Nix repo itself, using home-manager or module code), prefer the shorter
`pkgs.makeJailedPi {...}` form.

### Inside the Nix repo

Add a file `devshells/<name>.nix` and register it in
`devshells/default.nix`, following the existing pattern:

```nix
# devshells/<name>.nix
{
  pkgs,
  inputs,
}: let
  inherit (inputs.jail-nix.lib) init; # if combinators are needed, see below
in
  pkgs.mkShell {
    packages = [(pkgs.makeJailedPi {extraPkgs = [...];})];
    # So the outer `nix develop` env ALSO has the tools (for the user's own
    # shell); the jail ignores it and uses its own closure.
    packages = packages ++ [...];
  };
```

Then `nix develop ~/.nixos#<name>`.

## Choosing `extraPkgs` per language

Bake the whole toolchain INTO the closure. There is no `nix` and no shell
setup hooks inside the jail, so anything the build needs must be a package
in the closure:

- **Node**: `nodejs_22` (plus `pnpm`, `yarn`, `bun` if relevant). For
  compiling native addons (`node-gyp`), also add `python3` and a compiler:
  `stdenv.cc`. Native addons dlopen at runtime, so add
  `stdenv.cc.cc.lib`, `openssl.out`, `icu`, `zlib` if the addon needs them
  (icu/openssl/cc.lib are already in `commonPkgs`).
- **Python**: `python3` or versioned (`python312`, `python313`, ...).
  Do NOT rely on the host venv; inside the jail either use
  `pkgs.buildEnv`-style combined envs or add the needed wheels as nix
  packages (`python3.withPackages (ps: with ps; [...])` passes one env
  containing them). Virtualenvs created at runtime are fine, but `pip`
  resolve needs network (present) and compilers for source builds.
- **Rust**: `rustc`, `cargo`, `rustfmt`, `clippy`; for crates with C deps
  add `pkg-config` and the dev outputs of the specific libs. Because the
  jail has no stdenv setup hooks, multi-library native deps are easiest as
  a merged `.env` of dev outputs passed via a `buildEnv` package (see
  `godotBuildEnv` in `lib/jailed-pi.nix` for the pattern), referenced with
  `PKG_CONFIG_PATH` via a `set-env` combinator.
- **Go**: `go`.
- **JVM**: `jdk`, `maven` or `gradle` (note the default jail deliberately
  excludes these to stay small; adding them grows the closure substantially).
- **UE/engine work**: see `devshells/ue4-27.nix` for a heavy non-jail shell;
  a jail variant would pass the editor tooling via `extraPkgs`.
- **Project CLI**, linters, formatters the agent will run: add explicitly
  (e.g. `ruff`, `prettier`, `esbuild`, `golangci-lint`). The agent cannot
  `nix run` or npm/gem install into the system, so anything it may execute
  must be in the closure.

Rule of thumb: list every binary the agent might invoke. If it is not
there, the jail's `PATH` will not contain it.

## Other builder options

- `name ? "pi"`: wrapper script name.
- `extensionPackages`: pi extension packages, auto-loaded via `pi -e` with
  their node_modules closures pulled into the jail.
- `nugetPackages`: exposes a `/nuget` offline restore source + fallback
  folder to the jail's dotnet toolchain (for versioned custom NuGet
  packages, e.g. godot-mono forks).
- `extraCombinators`: requires importing `jail-nix.lib.init pkgs`
  yourself. Useful for env vars (`set-env`), extra read-write mounts
  (`readwrite`, `try-rw-bind`), network toggles, etc. See
  `lib/jailed-pi.nix` for the available combinators and detailed comments.

## Gotchas

1. The jail clears the environment. Env vars the tools need at runtime
   (e.g. `DOTNET_ROOT`, `PKG_CONFIG_PATH`, `SSL_CERT_FILE`, `DOCKER_HOST`)
   must be injected via `set-env` combinators in
   `extraCombinators`; PATH comes only from the closure's packages.
2. No build hooks: nobody runs `envSetupHooks`/`buildInputs` patchPhase
   inside the jail. Paths, rpath, and `PKG_CONFIG_PATH` are your job.
3. `~/.pi` and `~/.cache` are bound read-write, so pi settings, sessions,
   skills, extensions and npm/git caches persist across jail runs.
   Anything else in `$HOME` is ephemeral (tmpfs). The declarative agent
   skills bundle (`~/.agents/skills`, built from
   `~/.nixos/home/config/skills` by home-manager) is read-only inside the
   jail via an `agentSkills` ro-bind from `lib/jailed-pi.nix`.
4. The jail forwards network access and the host podman/docker socket
   (with `DOCKER_HOST` set); container builds/upstreams work without
   extra configuration.
5. The closure cost is real: language SDKs can add hundreds of MB. Only
   give the jail what this project actually needs.
6. Prefer `outputs.lib.makeJailedPi pkgs {...}` in external flakes over
   depending on node/npm installs, since those would vanish as soon as
   the jail restarts.
