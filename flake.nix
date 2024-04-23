{
  description = "Nix";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    master.url = "github:nixos/nixpkgs/master";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    nixvim,
    master,
    nix-colors,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    system = "x86_64-linux";

    username = "linus";
    desktop-hostname = "schnozzlecat";
    laptop-hostname = "schnozzlecat-laptop";
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = import ./pkgs nixpkgs.legacyPackages.${system};
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = nixpkgs.legacyPackages.${system}.alejandra;
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    master = inputs.master.legacyPackages.${system};

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      ${desktop-hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          master = self.master;
          hostname = desktop-hostname;
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
          self.nixosModules.sunshine
        ];
      };
      ${laptop-hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = laptop-hostname;
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "linus@schnozzlecat" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
          master = inputs.master.legacyPackages.${system};
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-desktop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
          self.homeManagerModules.sunshine
          self.homeManagerModules.godot4-mono-schnozzlecat
        ];
      };
      "linus@schnozzlecat-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
          master = inputs.master.legacyPackages.${system};
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-laptop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
