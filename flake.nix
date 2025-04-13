{
  description = "Nix";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    programs-db.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    hyprfocus = {
      url = "github:pyt0xic/hyprfocus";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-qtutils = {
      url = "github:hyprwm/hyprland-qtutils";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-citizen.url = "github:LovingMelody/nix-citizen";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    nixvim,
    nix-colors,
    # nix-citizen,
    lix-module,
    zjstatus,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (pkgs: import ./pkgs pkgs);
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (pkgs: pkgs.alejandra);
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      schnozzlecat-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "schnozzlecat-vm";
        };
        modules = [
          ./nixos/schnozzlecat-vm.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              self.homeManagerModules.godot4-mono-schnozzlecat
            ];
            home-manager.users.linus = import ./home/linus-vm.nix;
          }
        ];
      };
      schnozzlecat = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "schnozzlecat";
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
        ];
      };
      schnozzlecat-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "schnozzlecat-laptop";
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
        ];
      };
      schnozzlecat-server = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "schnozzlecat-server";
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/schnozzlecat-server.nix
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
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-desktop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
          self.homeManagerModules.sunshine
          self.homeManagerModules.godot4-mono-schnozzlecat
          inputs.spicetify-nix.homeManagerModules.default
        ];
      };
      "linus@schnozzlecat-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-laptop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
          self.homeManagerModules.sunshine
          self.homeManagerModules.godot4-mono-schnozzlecat
          inputs.spicetify-nix.homeManagerModules.default
        ];
      };
      "linus@schnozzlecat-server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-server.nix
          nix-colors.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
        ];
      };

      "linus@schnozzlecat-vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-vm.nix
          nix-colors.homeManagerModules.default
        ];
      };
    };
  };
}
