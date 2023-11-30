{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  services.xserver = {
    displayManager.sddm = {
      enable = true;
      settings.Theme.FacesDir = "${../secrets/avatars}";
      wayland.enable = true;
      theme = "chili";
    };
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "linus";
  };

  boot.blacklistedKernelModules = ["nouveau"];
  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["hid-nintendo" "v4l2loopoback"];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Printers
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brgenml1lpr
      brlaser
    ];
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };
}
