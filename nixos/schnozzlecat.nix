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
  boot.kernelModules = ["hid-nintendo" "v4l2loopback" "uinput"];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelParams = ["intel_iommu=on"];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  programs.virt-manager.enable = true;

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 linus qemu-libvirtd -"
  ];

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

  services.flatpak.enable = true;
  services.avahi.publish.userServices = true;

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };
}
