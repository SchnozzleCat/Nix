# buildPiExtension: build a *pi package directory* from a pinned git repo,
# ready to be loaded by the jailed pi agent via `extensionPackages`.
#
# Registered two ways, mirroring lib/jailed-pi.nix:
#
#   - pkgs.buildPiExtension { ... }       (via overlays.additions / pkgs/default.nix;
#     use this wherever a `pkgs` is already in scope, e.g. home/linus.nix)
#   - outputs.lib.buildPiExtension pkgs { ... }   (flake lib export, for
#     external flakes / devshells)
#
# Declarative mirror of the neovim external-plugin flow
# (home/neovim/extraPlugins.nix + buildPlugin in home/neovim/neovim.nix):
# an entry there is just `name = "owner/repo"` + pinned `version` + `hash`,
# and buildPlugin splits the name and calls fetchFromGitHub +
# buildVimPlugin. buildPiExtension is the pi analog: it splits
# "owner/repo", fetches the source at the pinned rev, and assembles a
# self-contained store path that `pi -e <store path>` loads:
#
#   package.json          (carries the `pi` manifest / `pi-package` keyword)
#   <everything else>     (extensions/, src/, skills/, ...: pi loads
#                          conventional dirs or whatever the manifest lists)
#   node_modules/         (npm `dependencies` populated when npmDepsHash is
#                          given; peerDependencies are NOT installed -- pi
#                          supplies @earendil-works/pi-* and typebox from
#                          its own bundle at load time, see pi docs
#                          packages.md "Dependencies")
#
# Consumers only specify the repo and its pin (see
# home/config/pi-extensions.nix for the list); npmDepsHash is the one
# extra piece npm packaging adds and is only needed for repos with
# runtime npm dependencies. Two escape hatches for repo-specific quirks:
# `patches` (source patches, e.g. npm lockfile integrity fixes -- both the
# npm deps fetch and the main build see the patched tree) and `pruned`
# (paths removed from the installed package dir). Entries can also pass
# `src` (fetch From GitLab etc.) or a prebuilt `pkg` -- see the callers.
{
  lib,
  applyPatches,
  buildNpmPackage,
  fetchFromGitHub,
  runCommand,
}: let
  # Same "owner/repo" split as the neovim buildPlugin utility.
  splitRepo = name: let
    parts = builtins.filter (e: !builtins.isList e) (builtins.split "/" name);
  in {
    owner = builtins.elemAt parts 0;
    repo = builtins.elemAt parts 1;
  };
in {
  buildPiExtension = {
    # "owner/repo" -- the repo is both the derivation name and the GitHub
    # repo; upstream package.json names are ignored for consistency.
    name,
    # Pinned git rev (tag or full SHA).
    version,
    # fetchFromGitHub hash; required unless `src` is given. First build
    # with `pkgs.lib.fakeHash`, then paste the "got: sha256-..." from the
    # failure output. (No-derivation shortcut: `nix --extra-experimental-features
    # 'nix-command flakes' flake prefetch github:owner/repo/<rev>` prints it.)
    hash ? null,
    # Optional explicit source override (e.g. fetchFromGitLab / fetchFromGitea).
    src ? null,
    # SRI hash of the npm dependency cache (nixpkgs fetchNpmDeps). Required
    # ONLY when the extension imports packages at runtime beyond what pi
    # itself provides (i.e. has npm `dependencies`); omit it for
    # dependency-free packages. First build with pkgs.lib.fakeHash, then
    # paste the "got: sha256-..." from the failure output into the spec.
    npmDepsHash ? null,
    # Extra flags for the offline `npm ci`. The defaults already do the
    # right thing for pi packages: --legacy-peer-deps stops npm from
    # auto-installing peerDependencies (pi provides them from its own
    # bundle; installing copies would shadow its extension module mapping),
    # and --omit=dev keeps devDependencies (typecheck/test tooling, and for
    # some repos a bundleable @earendil-works/* peer copy) out of the
    # package's node_modules.
    npmFlags ? [],
    # Source patches applied up front, before anything derives from the
    # source (the npm deps fetch included, which runs in a separate
    # derivation that only sees `src`). Typical use: upstream lockfiles
    # missing SRI integrity hashes, which buildNpmPackage's lock parser
    # rejects; drop the patch from the spec when upstream fixes the lock.
    patches ? [],
    # Paths (relative to the package root) removed from the installed
    # package directory. Typical use: dropping an extension whose load
    # behavior belongs to a different pi surface (agentic-af's
    # `permission` extension is pi.nvim-only and would otherwise stall
    # tool calls in the TUI). Removing the directory is enough -- the
    # package.json `pi` manifest glob then has nothing to load for it.
    pruned ? [],
  }: let
    split = splitRepo name;
    pruneCmds = lib.concatMapStringsSep "\n" (p: ''rm -rf "$out/${p}"'') pruned;
    fetchedSrc =
      if src != null
      then src
      else
        let
          _ =
            lib.assertMsg (hash != null) "`buildPiExtension` requires `hash` for GitHub sources (use pkgs.lib.fakeHash for the first build, then paste the got-hash).";
        in
          fetchFromGitHub {
            inherit (split) owner repo;
            rev = version;
            inherit hash;
          };
    # Patch before anything derives from the source: node fetchNpmDeps runs
    # in a separate derivation that only sees `src`, so the patch must be
    # in the tree up front or fetch and build read inconsistent locks.
    resolveSrc =
      if patches == []
      then fetchedSrc
      else
        applyPatches {
          name = "${split.repo}-source-patched";
          src = fetchedSrc;
          inherit patches;
        };
  in
    if npmDepsHash == null
    then
      # Dependency-free package: no npm machinery at all, just the source
      # tree as the pi package directory. NOTE: if the extension actually
      # imports an npm package at runtime this will fail at pi load time --
      # add npmDepsHash to the spec then.
      runCommand split.repo {} ''
        mkdir -p "$out"
        cp -a "${resolveSrc}"/. "$out/"
        ${pruneCmds}
      ''
    else
      buildNpmPackage {
        pname = split.repo;
        inherit version;
        src = resolveSrc;
        inherit npmDepsHash;

        # pi loads TypeScript extensions via jiti at runtime; there is no
        # build step. The npm phase exists purely to populate node_modules.
        # dontNpmCheck skips the standard checks (the pi package directory
        # is just a data payload).
        dontNpmBuild = true;
        dontNpmCheck = true;

        npmFlags = ["--legacy-peer-deps" "--omit=dev"] ++ npmFlags;

        installPhase = ''
          runHook preInstall
          # Assemble the pi package dir: the whole source tree -- package.json
          # with its `pi` manifest (or nothing, in which case pi uses
          # conventional discovery over extensions/, skills/, prompts/,
          # themes/), plus whatever those manifest globs / dirs point at --
          # and the populated node_modules symlink farm (npm deps store path
          # referenced by symlink). The reference scanner keeps the farm in
          # this derivation's closure, so the bwrap jail mounts it and the
          # extensions can resolve their runtime deps at load time.
          mkdir -p "$out"
          cp -a ./. "$out/"
          ${pruneCmds}
          runHook postInstall
        '';
      };
}
