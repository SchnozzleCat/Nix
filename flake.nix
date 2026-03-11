{
  description = "Nix";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-glaze.url = "github:nixos/nixpkgs/769af1cc90c29069f644425b5f259dba88bfad18";
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

    nix-software-center.url = "github:snowfallorg/nix-software-center";

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

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
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
    Hyprspace,
    nix-software-center,
    nixos-raspberrypi,
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
    homeModules = import ./modules/home-manager;

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
              self.homeModules.godot4-mono-schnozzlecat
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
      schnozzlecat-server = nixos-raspberrypi.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs nixos-raspberrypi;
          hostname = "schnozzlecat-server";
        };
        modules = [
          {
            # Hardware specific configuration, see section below for a more complete
            # list of modules
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-5.base
              raspberry-pi-5.page-size-16k
              raspberry-pi-5.display-vc4
              raspberry-pi-5.bluetooth
            ];
          }
          {
            boot.loader.raspberry-pi.bootloader = "kernel";
          }
          # > Our main nixos configuration file <
          ./nixos/schnozzlecat-server.nix
        ];
      };
      rpi5 = nixos-raspberrypi.lib.nixosSystemFull {
        specialArgs = inputs;
        modules = [
          inputs.home-manager.nixosModules.home-manager
          {
            hardware.raspberry-pi.config = {
              all = {
                # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters

                options = {
                  experimental-features = {
                    enable = true;
                    value = "nix-command flakes";
                  };

                  # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
                  # in conjunction with `console=serial0,115200` in kernel command line (`cmdline.txt`)
                  # creates a serial console, accessible using GPIOs 14 and 15 (pins
                  #  8 and 10 on the 40-pin header)
                  enable_uart = {
                    enable = true;
                    value = true;
                  };
                  # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
                  # enable debug logging to the UART, also automatically enables
                  # UART logging in `start.elf`
                  uart_2ndstage = {
                    enable = true;
                    value = true;
                  };
                };

                # Base DTB parameters
                # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
                base-dt-params = {
                  # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
                  pciex1 = {
                    enable = true;
                    value = "on";
                  };
                  # PCIe Gen 3.0
                  # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
                  pciex1_gen = {
                    enable = true;
                    value = "3";
                  };
                };
              };
            };
          }
          (
            {
              config,
              pkgs,
              lib,
              nixos-raspberrypi,
              ...
            }: {
              imports = with nixos-raspberrypi.nixosModules; [
                # Hardware configuration
                raspberry-pi-5.base
                raspberry-pi-5.display-vc4
              ];
            }
          )
          (
            {
              config,
              pkgs,
              ...
            }: {
              boot.loader.raspberryPi.bootloader = "kernel";
              fileSystems = {
                "/boot/firmware" = {
                  device = "/dev/disk/by-label/FIRMWARE";
                  fsType = "vfat";
                  options = [
                    "noatime"
                    "noauto"
                    "x-systemd.automount"
                    "x-systemd.idle-timeout=1min"
                  ];
                };
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                  options = ["noatime"];
                };
              };
            }
          )
          ({
            config,
            pkgs,
            ...
          }: {
            imports = [
              ./nixos/schnozzlecat-server.nix
              ./home/linus-server.nix
            ];
            system.nixos.tags = let
              cfg = config.boot.loader.raspberryPi;
            in [
              "raspberry-pi-${cfg.variant}"
              cfg.bootloader
              config.boot.kernelPackages.kernel.version
            ];
          })
          {
            boot.tmp.useTmpfs = true;
          }

          # Advanced: Use non-default kernel from kernel-firmware bundle
          (
            {
              config,
              pkgs,
              lib,
              ...
            }: let
              kernelBundle = pkgs.linuxAndFirmware.v6_6_31;
            in {
              boot = {
                loader.raspberryPi.firmwarePackage = kernelBundle.raspberrypifw;
                kernelPackages = kernelBundle.linuxPackages_rpi5;
              };

              nixpkgs.overlays = lib.mkAfter [
                (self: super: {
                  # This is used in (modulesPath + "/hardware/all-firmware.nix") when at least
                  # enableRedistributableFirmware is enabled
                  # I know no easier way to override this package
                  inherit (kernelBundle) raspberrypiWirelessFirmware;
                  # Some derivations want to use it as an input,
                  # e.g. raspberrypi-dtbs, omxplayer, sd-image-* modules
                  inherit (kernelBundle) raspberrypifw;
                })
              ];
            }
          )
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "linus@schnozzlecat" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            self.overlays.additions
            self.overlays.modifications
            self.overlays.unstable-packages
            self.overlays.master-packages
          ];
        };
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-desktop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeModules.nixvim
          self.homeModules.sunshine
          self.homeModules.godot4-mono-schnozzlecat
          inputs.spicetify-nix.homeManagerModules.default
        ];
      };
      "linus@schnozzlecat-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            self.overlays.additions
            self.overlays.modifications
            self.overlays.unstable-packages
            self.overlays.master-packages
          ];
        };
        extraSpecialArgs = {
          inherit inputs outputs nix-colors;
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home/linus-laptop.nix
          nix-colors.homeManagerModules.default
          nixvim.homeModules.nixvim
          self.homeModules.sunshine
          self.homeModules.godot4-mono-schnozzlecat
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
          nixvim.homeModules.nixvim
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
