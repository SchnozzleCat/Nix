{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    powertop
  ];

  services.logind.lidSwitch = "ignore";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.linuxKernel.packages.linux_latest_libre.cpupower}/bin/cpupower frequency-set --governor performance";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.linuxKernel.packages.linux_latest_libre.cpupower}/bin/cpupower frequency-set --governor powersave";
            options = ["NOPASSWD"];
          }
        ];
        groups = ["wheel"];
      }
    ];
  };

  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Enable WireGuard
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.0.0.2/24"];
      listenPort = 51111;
      privateKeyFile = "home/linus/.nixos/secrets/wireguard/private.key";

      peers = [
        {
          publicKey = "sfZOYpc0A6IagxOV1f6WlzwCrGN/VSXSNT6Jsb7DlQE=";
          allowedIPs = ["192.168.200.0/24"];
          endpoint = "trace.schnozzlecat.xyz:51111";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  boot.initrd = {
    luks.devices.root = {
      crypttabExtraOpts = ["fido2-device=auto"];
      device = "/dev/nvme0n1p1";
    };
    systemd.enable = true;
  };
  services.blueman.enable = true;

  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [224];
        events = ["key"];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      }
      {
        keys = [225];
        events = ["key"];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set +10%";
      }
    ];
  };
  hardware.cpu.intel.updateMicrocode = true;
}
