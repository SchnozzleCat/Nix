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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    nixos-hardware.url = "github:nixos/nixos-hardware";

    googleworkspace-cli.url = "github:googleworkspace/cli";

    # Dependency of lib/jailed-pi.nix (the bwrap sandbox the jailed pi
    # coding agent runs in), pinned like nixpkgs. See lib/jailed-pi.nix.
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";

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
    nixos-hardware,
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

    # Dev shells: `nix develop ~/.nixos#<name>` (e.g. ue4-27 for Unreal Engine)
    devShells = forAllSystems (pkgs: import ./devshells {inherit pkgs inputs;});
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeModules = import ./modules/home-manager;

    # Shared library functions. Also reachable as pkgs.makeJailedPi wherever
    # the additions overlay is applied.
    lib = {
      # bwrap-sandboxed pi coding agent; see lib/jailed-pi.nix for docs.
      # Usage: outputs.lib.makeJailedPi pkgs { extraPkgs = [...]; }
      makeJailedPi = pkgs:
        import ./lib/jailed-pi.nix {
          inherit pkgs;
          jail-nix = inputs.jail-nix;
        };
    };

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
      rpi5 = nixpkgs.lib.nixosSystem {
        # Native aarch64 evaluation: mostly binary-cache hits, no cross toolchain
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops

          # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_5
          # Downstream RPi kernel (built on Hydra/cache), VC4 KMS, extlinux boot
          inputs.nixos-hardware.nixosModules.raspberry-pi-5

          # SD image support: `nix build
          # .#nixosConfigurations.rpi5.config.system.build.sdImage`
          # (builds fine on x86_64 thanks to boot.binfmt.emulatedSystems).
          # MBR + bootable flag, FIRMWARE/NIXOS_SD labels (matches the
          # fileSystems below). nixos-hardware's firmware module overrides
          # sdImage.populateFirmwareCommands with its own staging script.
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

          {
            hardware.raspberry-pi.configtxt.settings = {
              all = {
                # NOTE: deliberately NOT enabling the UART here.
                # With U-Boot in the boot chain (hardware.raspberry-pi.firmware.uboot),
                # the mini UART's floating RX feeds ghost input into U-Boot and hangs
                # the boot at the U-Boot splash. The nixos-hardware profile disables
                # it for Pi 5 for exactly this reason; leave pi5.enable_uart = false.
                # If serial debugging on the debug connector is ever needed:
                #   pi5.enable_uart = lib.mkForce true;
                #   boot.kernelParams = [ "console=ttyAMA10,115200n8" ];
                # and keep a (grounded) 3.3V adapter attached.
                # Base DTB parameters
                # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
                pciex1 = "on";
                # PCIe Gen 3.0
                # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
                pciex1_gen = "3";
              };
            };
          }

          { boot.tmp.useTmpfs = true; }

          (
            {
              config,
              pkgs,
              lib,
              ...
            }: {
              # sd-image.nix pulls in the all-hardware profile (installer
              # image kitchen sink); its initrd module list names modules
              # the RPi vendor kernel doesn't build (dw-hdmi etc.), which
              # breaks the initrd module shrink (modprobe FATAL). This
              # image only ever boots on this one Pi 5, whose needs the
              # nixos-hardware profile already covers.
              hardware.enableAllHardware = lib.mkForce false;

              # Stage GPU firmware, device trees, overlays, U-Boot and
              # config.txt onto the firmware partition on every switch
              hardware.raspberry-pi.firmware = {
                enable = true;
                uboot.enable = true;
                # Stage device trees from the booted generation (the RPi
                # kernel this profile builds) instead of the vendor
                # raspberrypifw package. The vendor DTBs list the debug
                # UART (uart10, serial@7d001000, the stdout-path console)
                # as compatible "arm,pl011-axi", which U-Boot's pl01x
                # driver cannot bind: U-Boot draws its splash logo and
                # then hangs before reading extlinux.conf. The kernel
                # DTS (bcm2712.dtsi) uses plain "arm,pl011" and boots.
                # (Image builds can't use /run/current-system/dtbs, so
                # they fall back to the package below - which is patched.)
                useGenerationDeviceTree = true;
                # Patched vendor firmware: all bcm2712* DTBs get uart10's
                # compatible fixed up, covering the image-build path and
                # every board stepping (incl. bcm2712d0-rpi-5-b.dtb).
                package = pkgs.callPackage ./pkgs/raspberrypifw-uart10 {};
              };
              # extlinux.conf + kernels go to /boot on the root ext4
              # (stock sd-image layout, default mirroredBoots) - keeps the
              # small FAT firmware partition untouched by generations and
              # avoids the noauto/automount mount timing issues.
              # boot.loader.generic-extlinux-compatible.mirroredBoots uses
              # its default [{ path = "/boot"; }] now.
              sdImage = {
                # GPU firmware + DTBs + overlays + U-Boot only (kernels live
                # on the root partition via extlinux); 256M is comfortable.
                firmwareSize = 256;
                # Uncompressed .img, easier to inspect and flash with dd.
                compressImage = false;
              };
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
            system.nixos.tags = [
              "raspberry-pi-5"
              config.boot.kernelPackages.kernel.version
            ];
          })
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
