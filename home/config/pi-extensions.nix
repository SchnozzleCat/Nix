# Declarative pi extensions for the jailed pi agent (extensionPackages of
# pkgs.makeJailedPi). Mirrors the neovim external-plugin pattern
# (home/neovim/extraPlugins.nix + buildPlugin in home/neovim/neovim.nix):
# each entry is either
#
#   { pkg = <pi package derivation>; }         -- already-built package
#                                                 directory, e.g. pkgs.agentic-af
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
# When bumping `version`, refresh `hash` and `npmDepsHash` the usual way
# (fake hash first, then paste the "got: sha256-..." from the failures).
{pkgs}:
[
  {pkg = pkgs.agentic-af;}
  {
    name = "elidickinson/pi-claude-bridge";
    version = "4cde27e88c143b6e80b9e6452629df72ef4e2496";
    hash = "sha256-AdoX9TMFInomCDhyh7PLW/nGcZLRJMwCnvtWPw/wbgg=";
    npmDepsHash = "sha256-nS1KZnHHwTVV7B32tc7B7ZYssoPbKLo9GcXZr2Shot8=";
  }
]
