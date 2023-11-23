{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

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
