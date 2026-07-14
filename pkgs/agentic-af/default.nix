{
  lib,
  buildNpmPackage,
  applyPatches,
  src,
  withPermission ? false,
}:
# Source comes from the `agentic-af` flake input in flake.nix
# (`url = "github:alex35mil/agentic-af/<rev>"; flake = false;`), so it's a
# plain fetched store path, not a flake. `pkgs/default.nix` passes it in as
# the `src` argument.
#
# This builds a *pi package directory*: a self-contained store path that
# pi loads via `pi -e $out`. It contains `package.json` (which carries the
# `pi` manifest pointing at `./extensions`), the `extensions/` tree (six
# extension subdirectories each with an `index.ts`, plus the shared
# `extensions/__lib`), and a populated `node_modules/` so the extensions
# can resolve their runtime deps at load time:
#   @modelcontextprotocol/sdk, jsdom, @mozilla/readability, turndown,
#   turndown-plugin-gfm
#
# `withPermission` controls whether the `permission/` extension is shipped.
# It defaults to false because the jailed pi here is the TUI build, and
# `permission` is built for pi.nvim: its edit-review flow drives the Neovim
# plugin, and its allow/deny/ask rules would otherwise stall tool calls in
# the TUI. Set `withPermission = true` if you ever build this for a
# pi.nvim-backed (non-jailed) pi.
#
# The `@earendil-works/*` and `typebox` peerDependencies are intentionally
# *not* installed here -- pi provides them from its own bundle when it
# loads the package (see pi's packages.md "Dependencies"). They are absent
# from `package-lock.json`, so `fetchNpmDeps` never pulls them.
# Patch `package-lock.json` before handing the source to `buildNpmPackage`.
# Upstream's lock is missing integrity hashes on three peer-dependency
# entries nested under `@earendil-works/pi-coding-agent` (pi-agent-core,
# pi-ai, pi-tui) -- npm resolved them transitively but didn't write SRI
# hashes. `buildNpmPackage`'s Rust lock parser panics on that
# ("non-git dependencies should have associated integrity"), so we inject
# the hashes here. We patch via `applyPatches` (not the derivation's
# `patches` attr) because `buildNpmPackage` runs `fetchNpmDeps` in a
# *separate* derivation that only sees `src` -- applying the patch to the
# source tree up front means both the deps fetch and the main build read a
# consistent, complete lock. If upstream fixes the lock, drop this and the
# `applyPatches` plumbing.
let
  patchedSrc = applyPatches {
    name = "agentic-af-source-patched";
    inherit src;
    patches = [./package-lock-integrity.patch];
  };
in
  buildNpmPackage {
    pname = "agentic-af";
    # Upstream package.json ships no `version` field; pin one for the
    # derivation name. Bump it if you ever pin a different rev.
    version = "0.1.0";

    src = patchedSrc;

    # The package has no build step: tsconfig.json is `noEmit`, there are no
    # npm `scripts`, and pi loads the TypeScript extensions via jiti at
    # runtime. We only need `npm install` to populate `node_modules`.
    dontNpmBuild = true;
    dontNpmCheck = true;

    # npm 7+ auto-installs missing `peerDependencies`; pi provides those at
    # runtime from its own bundle (see packages.md "Dependencies"), so our
    # `fetchNpmDeps` cache deliberately omits `@earendil-works/pi-*` and
    # `typebox`. Without this flag the main `npm install` fails with
    # `ENOTCACHED` for, e.g., `@earendil-works/pi-tui` because npm tries to
    # fetch the missing peer from the network in offline mode. `--legacy-
    # peer-deps` restores npm 6's "do not auto-install peers" behavior and
    # lets pi supply them when it loads the package via `pi -e $out`.
    #
    # Adding/changing `npmFlags` may change which deps land in the offline
    # cache: if a subsequent build says the `npmDepsHash` no longer matches,
    # paste the new "got: sha256-..." from the error into `npmDepsHash`.
    npmFlags = ["--legacy-peer-deps"];

    # `package-lock.json` is lockfileVersion 3.
    npmDepsHash = "sha256-ogpjpnT1mnW/h+0wAf1k4UL6/etvyZfNtJLMezrniIM=";

    installPhase = ''
      runHook preInstall
      # Assemble the pi package dir: the manifest + extensions + deps. `cp -r`
      # preserves the `node_modules` symlink farm (pointing into the fetched
      # npmDeps store path), which Nix's reference scanner keeps in this
      # derivation's closure so the sandbox can mount it.
      mkdir -p $out
      cp -r package.json extensions node_modules $out/
      ${lib.optionalString (! withPermission) ''
        # Drop the pi.nvim-only permission extension for the TUI build (see
        # `withPermission` above). Removing the directory is enough -- the
        # package.json `pi.extensions` glob then has nothing to load for it.
        rm -rf $out/extensions/permission
      ''}
      runHook postInstall
    '';
  }
