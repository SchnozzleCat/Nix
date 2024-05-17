{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-schnozzlecat-server.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  users.users = {
    linus = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "password";
      createHome = true;
      home = "/home/linus";
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
