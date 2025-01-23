{
  inputs,
  outputs,
  master,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: let
  pinPackage = {
    name,
    commit,
    sha256,
  }:
    (import (builtins.fetchTarball {
      inherit sha256;
      url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
    }) {system = pkgs.system;})
    .${name};
in {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

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

  services.ollama = {
    enable = true;
    package = pinPackage {
      name = "ollama";
      commit = "d0169965cf1ce1cd68e50a63eabff7c8b8959743";
      sha256 = "sha256:1hh0p0p42yqrm69kqlxwzx30m7i7xqw9m8f224i3bm6wsj4dxm05";
    };
    host = "0.0.0.0";
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.1";
  };

  boot.blacklistedKernelModules = ["nouveau"];
  hardware.cpu.intel.updateMicrocode = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", MODE="0666", GROUP="plugdev"
  '';

  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["hid-nintendo" "v4l2loopback" "uinput"];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
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
    nssmdns4 = true;
    openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  services.flatpak.enable = true;
  services.avahi.publish.userServices = true;

  environment.systemPackages = with pkgs; [
    inputs.nix-citizen.packages.x86_64-linux.star-citizen
  ];

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };
}
