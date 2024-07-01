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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
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
          endpoint = "roamer.servebeer.com:51111";
          persistentKeepalive = 25;
        }
      ];
    };
  };
  services.blueman.enable = true;

  sound.mediaKeys.enable = true;
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

  services.xserver.videoDrivers = ["nvidia"];

  services.thermald.enable = true;
  services.auto-cpufreq.settings = {
    enable = true;
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  security.pam.yubico = {
    enable = true;
    debug = false;
    mode = "challenge-response";
    id = ["23767516"];
    control = "required";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.cpu.intel.updateMicrocode = true;
}
