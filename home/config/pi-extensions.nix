# Declarative pi extensions for the jailed pi agent (extensionPackages of
# pkgs.makeJailedPi). Mirrors the neovim external-plugin pattern
# (home/neovim/extraPlugins.nix + buildPlugin in home/neovim/neovim.nix):
# each entry is either
#
#   { pkg = <pi package derivation>; }         -- already-built package
#                                                 directory
#   { name = "owner/repo"; version = <rev>;    -- fetched from GitHub and
#       hash = "..."; npmDepsHash = "..."; }      built by
#                                                 pkgs.buildPiExtension
#                                                 (lib/pi-extension.nix),
#                                                 which handles the
#                                                 owner/repo split,
#                                                 fetching, npm layer
#                                                 and node_modules.
#
# The caller (home/linus.nix) maps this list over the pkg/build split, so
# adding an upstream extension is just the name + pinned rev + hashes.
# `buildPiExtension` also accepts `patches` (source patches, e.g. the
# agentic-af lockfile fix) and `pruned` (paths dropped from the installed
# package dir, e.g. extensions only meant for pi.nvim).
#
# Hash recipe when pinning/bumping a repo: run
#   nix --extra-experimental-features 'nix-command flakes' \
#     flake prefetch github:<owner>/<repo>/<rev>
# to get `hash`, then set `npmDepsHash` to pkgs.lib.fakeHash and paste the
# "got: sha256-..." into the spec from the failed build.
{pkgs}:
[
  {
    name = "alex35mil/agentic-af";
    version = "2b100534808ee99c0085214b1583db7877ef73bf"; # main, 2026-11-05
    hash = "sha256-hoydlP1Zc3FRMHO9ZTansFeUO7/aDo6tVRsn+ktE6Fw=";
    npmDepsHash = "sha256-Vj91V5flg+xB2NY96cJzCjlVq9g2O3o1dfBYO9oeJ18=";
    # Drop for the jailed pi TUI build:
    #   extensions/permissions -- pi.nvim-driven edit-review flow (and its
    #     allow/deny/ask rules would otherwise stall tool calls in the TUI;
    #     was extensions/permission [singular] at the old 5505c49 pin).
    #   workflows -- the Epic/Task/Gig suite; requires a GitHub/Linear
    #     tracker and PR forge credentials, i.e. exactly the host gh/secret
    #     plumbing the jail's commonPkgs deliberately excludes (see
    #     lib/jailed-pi.nix). The package.json manifest globs
    #     (./workflows/extensions, ./workflows/skills) simply load nothing
    #     with the directory gone. Revisit if you ever wire tracker creds
    #     into the jail.
    pruned = ["extensions/permissions" "workflows"];
  }
  {
    name = "elidickinson/pi-claude-bridge";
    version = "4cde27e88c143b6e80b9e6452629df72ef4e2496";
    hash = "sha256-AdoX9TMFInomCDhyh7PLW/nGcZLRJMwCnvtWPw/wbgg=";
    npmDepsHash = "sha256-nS1KZnHHwTVV7B32tc7B7ZYssoPbKLo9GcXZr2Shot8=";
  }
]
