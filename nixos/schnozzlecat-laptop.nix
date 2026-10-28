{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: let
  # Builds a oneshot ExecStart script that applies a power-profiles-daemon
  # profile. Used by the AC/battery udev-triggered services below.
  ppdProfile = name: profile:
    pkgs.writeShellScript name ''
      export PATH=${pkgs.power-profiles-daemon}/bin:$PATH
      powerprofilesctl set ${profile}
    '';
in {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    powertop
  ];

  services.logind.lidSwitch = "suspend";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Disk mounting / file manager plumbing, matching the desktop.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # sched-ext userspace scheduler, matching the desktop.
  services.scx.scheduler = "scx_bpfland";

  powerManagement.enable = true;

  services.thermald.enable = true;

  security.pam.services.sddm.fprintAuth = true;

  # Power management via power-profiles-daemon (kept for noctalia's
  # power-profile widget: sometimes we want turbo even on battery).
  # Auto-switching without auto-cpufreq: udev fires on AC plug/unplug and
  # pokes a oneshot service that applies the matching profile.
  #   - AC  -> performance (full turbo)
  #   - bat -> power-saver (platform_profile; Framework's firmware-tuned
  #           low-power mode, better than a raw governor pin)
  # Manual profile choice via the widget is respected until the next
  # plug/unplug event (only AC adapters trigger the rules -- battery
  # capacity uevents are ignored, so flipping to performance on battery
  # sticks).
  services.udev.extraRules = ''
    # POWER_SUPPLY_TYPE=Mains matches AC adapters only (not batteries).
    # ACTION add covers coldplug/boot so the initial state is synced too.
    SUBSYSTEM=="power_supply", ACTION=="add|change", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.systemd}/bin/systemctl start --no-block ppd-profile-ac.service"
    SUBSYSTEM=="power_supply", ACTION=="add|change", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.systemd}/bin/systemctl start --no-block ppd-profile-battery.service"
  '';

  systemd.services = {
    ppd-profile-ac = {
      description = "Apply performance power profile (AC connected)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ppdProfile "ppd-ac" "performance";
      };
    };
    ppd-profile-battery = {
      description = "Apply power-saver power profile (on battery)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ppdProfile "ppd-battery" "power-saver";
      };
    };
  };

  sops.secrets.wg-laptop-private = {};

  # SSH for remote deploys (desktop pushes nix closures over this, see the
  # laptop-build alias) and general management. Mirrors the desktop setup.
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

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.0.0.2/24"];
      listenPort = 51111;
      privateKeyFile = config.sops.secrets.wg-laptop-private.path;

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
  };
  services.blueman.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
}
