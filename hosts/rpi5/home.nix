# home-manager config for the Pi server, wired through the NixOS module
# (instead of the desktops' standalone HM flake entry).
# Uses home/linus-server.nix - the lean headless profile (fish, starship, a
# few terminal tools) rather than the full desktop terminal.nix: the full
# desktop home means multi-minute native aarch64 builds on the Pi
# (neovim-nightly + its mkdocs/copier python deps, incl. timing-flaky test
# suites like backrefs and neovim's treesitter specs).
{
  ...
}: {
  home-manager = {
    useUserPackages = true;

    # Conflicts with pre-existing dotfiles get backed up instead of failing
    # activation on first switch.
    backupFileExtension = "hm-backup";

    users.linus = {
      imports = [
        ../../home/linus-server.nix
      ];

      systemd.user.startServices = "sd-switch";

      home.stateVersion = "25.05";
    };
  };
}
