# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{...}: {
  home-manager.users.linus = {
    systemd.user.startServices = "sd-switch";

    home = {
      stateVersion = "25.05";

      file.".cloudflared/729e667c-0deb-4724-8614-97f8827279db.json".source =
        ../secrets/cloudflared/729e667c-0deb-4724-8614-97f8827279db.json;
      file."wireguard-keys/public.key".source = ../secrets/wireguard/public-pi.key;
      file."wireguard-keys/private.key".source = ../secrets/wireguard/private-pi.key;
    };
  };
}
