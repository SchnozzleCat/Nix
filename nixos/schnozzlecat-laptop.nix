{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: let
  my-alsa-ucm = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
    # Override the source to use the Git snapshot
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/fc17ed4.tar.gz";
      sha256 = "sha256:0krh3r9frzjcv0gj85dljb9776mfjmw18m0ph9lf3n0n4b129xzz";
    };
    # Override the installPhase to avoid problematic substitutions
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    # Disable postInstall to avoid substitutions
    postInstall = "";
  });

  env = {
    ALSA_CONFIG_UCM = "${my-alsa-ucm}/share/alsa/ucm";
    ALSA_CONFIG_UCM2 = "${my-alsa-ucm}/share/alsa/ucm2";
  };
in {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    powertop
    my-alsa-ucm
    alsa-firmware
    alsa-topology-conf
  ];

  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM =
    config.environment.variables.ALSA_CONFIG_UCM;
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM =
    config.environment.variables.ALSA_CONFIG_UCM;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;

  # sound
  hardware.firmware = [
    pkgs.sof-firmware # Intel sound DSP firmware
    pkgs.linux-firmware # includes cs35l56-* & friends
    pkgs.alsa-firmware
  ];

  environment.variables = env;
  environment.sessionVariables = env;

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

  boot.kernelParams = ["usbcore.autosuspend=-1"];
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  users.users.linus.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3tGusi1VdNxad/qMykPp5l8aHMivjP9qUfKZ7uwBNh0aLtMvT8qGBam/TQMXoIrIvCq9K/hQR2LetsQ/+NmVdMS6Ejt1XGP90N0AoMIUbmMOF61JgUJv5NYS/O+7iEgAlVoyGylznufiaDk0pFrBKWVLHYsQASta5aZsnSdL1xTI5fEhjdLZpOslOStI43yY5IdsAkOpjcN6Z1eirTz0Ztft3bM0uNwNERMGHJ98EOsTMXBaTmU0js2q5el/9d08Y3mJ+5RQqm22hK+xFBdTIt5prvOO+sl6ywk/itCkfeDwKX2T3fhmEXwzS/83erRPvTrYZmguF541fHsYehFhyDWI+UE2enaSe6mXAY79dphajy1dIhph/uF18Im3mA5zHyCTrPPt+0SuneAPrnZCUagUB0QY15TD7LI/CcN+MxZazQULdX+Xsg4LC4QOg+1nPNVPosIXiwNLzGmGcow4LyUuUhRbz3UwyVMj6SKyVdXk9dc+8xGladq0GL9G+7Eg8cz1xzZOa4DzDc40Mk85EsNOWZqltgt+jTuGnIOS377U0nlmqpUURyu1jOQxylQQb7J0ESPiwvP/lb2q/GPTYDuYcslTPYoCSWd2LX5BGB5mAvQ9l9ocu26DZWB0sGp/kw13f2RxC7v7OEwvlNHD+2Vlokzhr0HyZasm0oV2y/w== openpgp:0x957E5326"
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    ports = [
      6969
    ];
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
