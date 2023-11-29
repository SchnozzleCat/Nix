{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  colorScheme = {
    slug = "schnozzlecat";
    name = "schnozzlecat";
    colors = {
      base00 = "#1F1F28";
      base01 = "#2a273f";
      base02 = "#393552";
      base03 = "#6e6a86";
      base04 = "#908caa";
      base05 = "#e0def4";
      base06 = "#e0def4";
      base07 = "#56526e";
      base08 = "#eb6f92";
      base09 = "#f6c177";
      base0A = "#ea9a97";
      base0B = "#3e8fb0";
      base0C = "#9ccfd8";
      base0D = "#c4a7e7";
      base0E = "#f6c177";
      base0F = "#56526e";
    };
  };

  programs.looking-glass-client = {
    enable = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home.packages = with pkgs; [
    obs-studio
    obs-studio-plugins.wlrobs
    obs-studio-plugins.looking-glass-obs
    (writeShellApplication {
      name = "swap-audio";
      text = ''
        #!/bin/bash
        sink=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)
        if [[ $sink == "alsa_output.pci-0000_00_1f.3.analog-stereo" ]]; then
          ${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.usb-C-Media_Electronics_Inc._USB_Multimedia_Audio_Device-00.analog-stereo
        else
          ${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
        fi
      '';
    })
  ];

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config pkgs;})
    + ''
      monitor=DP-1,3440x1440@144,0x0,1
      monitor=DP-2,1920x1080@60,0x-1080,1
      monitor=DP-3,1920x1080@60,1920x-1080,1
      monitor=HDMI-A-1,1920x1080@60,3440x-1080,1

      workspace=DP-1,1
      workspace=DP-1,2
      workspace=DP-1,3
      workspace=DP-2,4
      workspace=DP-3,5

      bind = $mainMod, 1, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers1.png}"
      bind = $mainMod, 2, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers5.png}"
      bind = $mainMod, 3, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers6.png}"
      bind = $mainMod,o,exec, swap-audio
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = DP-1,${../secrets/wallpapers/flowers1.png}
      wallpaper = DP-2,${../secrets/wallpapers/flowers2.png}
      wallpaper = DP-3,${../secrets/wallpapers/flowers3.png}
      wallpaper = HDMI-A-1,${../secrets/wallpapers/flowers4.png}
    '';
}
