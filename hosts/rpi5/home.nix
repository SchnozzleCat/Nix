# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{...}: {
  home-manager.users.linus = {
    systemd.user.startServices = "sd-switch";

    home.stateVersion = "25.05";
  };
}
