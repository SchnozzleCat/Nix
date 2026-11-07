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
{pkgs}: [
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
  # Claude Code subscription provider. Unlike pi-claude-bridge it does
  # NOT depend on the Agent SDK's bundled claude binary: it spawns the
  # real `claude` CLI (`claude -p`, so PATH/name configurable via
  # PI_CLAUDE_CODE_COMMAND). `claude-code` (nixpkgs; autoPatchelfed
  # official bun binary) is added to the jail's extraPkgs in
  # home/linus.nix, and ~/.claude(+.json) are rw-bound in
  # lib/jailed-pi.nix so the `claude auth login` state persists.
  # Dependency-free (peerDeps only), hence no npmDepsHash.
  {
    name = "earendil-works/pi-claude-code";
    version = "d5b5e04c314d3452d357174d16d10dda34daa2d2"; # main, 2026-11-05
    # Drop PR #23 (CLAUDE_CODE_ENTRYPOINT=pi-agent): with Anthropic's
    # extra-usage rule live, that unrecognized entrypoint gets every
    # request classified as third-party and blocked; bare sdk-cli (the
    # default for headless runs) still draws from plan limits. Verified
    # applying cleanly against the pin. See the comment in the patch and
    # repo issue #22. Revisit when upstream settles the entrypoint story.
    patches = [./patches/pi-claude-code-drop-entrypoint.patch];
    hash = "sha256-86zfGr9YoM+I/PmWHDJb8AbcxhYC1m8aOeghJjvN414=";
  }
]
