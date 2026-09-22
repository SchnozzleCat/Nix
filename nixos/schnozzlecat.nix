{
  inputs,
  outputs,
  master,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  # Bleeding-edge Mesa (git main) with AMD-only drivers. Used as a workaround
  # for Crimson Desert 1.05 respawn-time GPU wedges; community reports the
  # crash stops on Mesa Git but persists on nixos-unstable Mesa 26.1.x stable.
  # The module sets hardware.graphics.package / package32 for us.
  imports = [
    inputs.mesa-git-nix.nixosModules.default
  ];

  nixpkgs.overlays = [
    inputs.mesa-git-nix.overlays.default
  ];

  mesa-git = {
    enable = true;
    drivers = ["amd"]; # 6950 XT only — keep build time sane
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services.scx.scheduler = "scx_bpfland";

  networking.interfaces."enp8s0".wakeOnLan = {
    enable = true;
    policy = ["magic"];
  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # boot.blacklistedKernelModules = ["nouveau"];
  hardware.cpu.intel.updateMicrocode = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", MODE="0666", GROUP="plugdev"
  '';

  hardware.i2c.enable = true;

  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = [
    "hid-nintendo"
    "v4l2loopback"
    "uinput"
    "kvmfr"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback kvmfr];
  # Looking Glass IVSHMEM via the kvmfr module.
  # static_size_mb must match the 'size' in the VM's ivshmem memory-backend
  # exactly. Formula: width*height*4 bytes, rounded up to a power of 2, x2.
  # 1440p -> 32MB, 4K -> 64MB.
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    options kvmfr static_size_mb=64
  '';
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "pcie_aspm=off"
    "amdgpu.runpm=0"
    # Force GPUVM page-table updates through the CPU (via the PCIe BAR) instead
    # of through the GPU's SDMA copy engines. Default is SDMA, which is faster
    # but shares the GPU's memory fabric with the graphics/compute rings --
    # under Crimson Desert's heavy respawn-time resource rebuild burst, SDMA
    # can stall waiting on memory arbitration, wedging the GPU silently.
    # Modes: 0=SDMA everywhere, 1=CPU for graphics, 2=CPU for compute,
    # 3=CPU for both. We use 3 to remove SDMA VM-update pressure entirely.
    # Cost: slightly slower CPU-driven page-table updates (small memory stores
    # over PCIe + TLB-flush ioctl); in practice unmeasurable on a Gen4 x16 link.
    # WARNING: emits 'WARNING: drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c:2631' on
    # boot when a KFD compute VM is created -- this is a known artifact of the
    # CPU-VM-update path, NOT a fault.
    #
    # Bisection evidence for keeping this on:
    #   - Added it alongside other speculative params: silent wedge stopped
    #   - Removed it in a cleanup pass: silent wedge returned (plus new
    #     'perf: interrupt took too long' warnings firing before the wedge)
    #   - Re-added 2026-07-23 after the revert-test correlated the symptom.
    "amdgpu.vm_update_mode=3"
    "reboot=acpi"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    # virtiofsd for virtiofs shared folders (9p has no Windows guest driver).
    # Packaged into the qemu wrapper so libvirt can find it at domain start.
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  # The unprivileged qemu user must be able to open /dev/kvmfr0 (group kvm,
  # mode 0660 via the udev rule) for the Looking Glass ivshmem backend.
  users.users."qemu-libvirtd".extraGroups = ["kvm"];
  programs.virt-manager.enable = true;

  # udev rule for the kvmfr char device. Must go through services.udev
  # (environment.etc under udev/rules.d conflicts with the udev module).
  # Named 65- so it sorts before 73-seat-late.rules, required for
  # TAG+="uaccess" to take effect.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "kvmfr-udev-rules";
      destination = "/etc/udev/rules.d/65-kvmfr.rules";
      text = ''
        SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
      '';
    })
  ];

  # libvirtd applies a device cgroup ACL to the qemu process; /dev/kvmfr0 is
  # not in the default list, so re-declare it (this overrides the default
  # list, hence the full set).
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm",
      "/dev/rtc", "/dev/hpet",
      "/dev/vfio/vfio",
      "/dev/kvmfr0"
    ]
  '';

  # VM shared folder: qemu runs unprivileged (runAsRoot = false) as
  # qemu-libvirtd, so grant it traversal + access via ACLs instead of
  # loosening home-dir permissions. The "x"-only ACL on ~ lets it traverse
  # but not list; default ACLs apply to newly created files.
  systemd.tmpfiles.rules = [
    "a+ /home/linus           - - - - u:qemu-libvirtd:x"
    "a+ /home/linus/Mounts    - - - - u:qemu-libvirtd:r-x"
    "a+ /home/linus/Mounts/vm - - - - u:qemu-libvirtd:rwx"
    "a+ /home/linus/Mounts/vm - - - - d:u:qemu-libvirtd:rwx"
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
    nssmdns4 = true;
    openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
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

  services.flatpak.enable = true;
  services.avahi.publish.userServices = true;

  environment.systemPackages = with pkgs; [
    # inputs.nix-citizen.packages.x86_64-linux.star-citizen
  ];

  hardware.amdgpu.overdrive = {
    enable = true;
    ppfeaturemask = "0xffffffff";
  };

  programs.corectrl = {
    enable = true;
  };
}
