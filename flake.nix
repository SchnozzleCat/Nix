{
  description = "Nix";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-qtutils = {
      url = "github:hyprwm/hyprland-qtutils";
      # Follow the main nixpkgs like the rest of the hyprland ecosystem
      # inputs do. Without this, qtutils pins its own (older) nixpkgs, which
      # (a) adds a second nixpkgs evaluation to the closure and (b) triggers
      # Lix's "or as an identifier" deprecation warnings from that old
      # nixpkgs' lib every eval.
      inputs.nixpkgs.follows = "nixpkgs";
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

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    googleworkspace-cli.url = "github:googleworkspace/cli";

    pi-jail = {
      # The narHash is pinned because CppNix and Lix disagree on how to lock
      # relative-path "subflake" inputs: CppNix writes them WITHOUT narHash
      # (using a `parent` field Lix doesn't support), and Lix refuses to read
      # hash-less path nodes ("lock file contains mutable lock"). A narHash
      # pinned in the URL is the one form both accept.
      #
      # RITUAL: whenever you edit anything under flakes/pi-jail, the next
      # build fails with "NAR hash mismatch in input ... expected ... got ..."
      # -- paste the 'got' hash (percent-encode '+' as %2B and '=' as %3D)
      # into this URL.
      url = "path:./flakes/pi-jail?narHash=sha256-b9txS/dhy%2BcMFvq6PKDU0RUA6mn9Wgx5YYnBNkIrp5g%3D";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agentic-af = {
      url = "github:alex35mil/agentic-af/5505c49da4dd7a0171e6b921ad809f7636db02b7";
      flake = false;
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mesa-git-nix = {
      url = "github:Daaboulex/mesa-git-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nix-colors,
    # nix-citizen,
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
    packages = forAllSystems (pkgs: import ./pkgs {inherit pkgs inputs;});
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
              boot.loader.raspberry-pi.bootloader = "kernel";
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
              ./hosts/rpi5/server.nix
              ./hosts/rpi5/home.nix
            ];
            system.nixos.tags = let
              cfg = config.boot.loader.raspberry-pi;
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
                loader.raspberry-pi.firmwarePackage = kernelBundle.raspberrypifw;
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
          self.homeModules.godot4-mono-schnozzlecat
          inputs.nix-index-database.homeModules.nix-index
        ];
      };
      "linus@schnozzlecat-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            self.overlays.additions
            self.overlays.modifications
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
          self.homeModules.godot4-mono-schnozzlecat
          inputs.nix-index-database.homeModules.nix-index
        ];
      };
    };
  };
}
