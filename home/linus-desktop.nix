{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  master,
  nix-colors,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  colorScheme = {
    slug = "schnozzlecat";
    name = "schnozzlecat";
    palette = {
      base00 = "#192330";
      base01 = "#212e3f";
      base02 = "#29394f";
      base03 = "#575860";
      base04 = "#71839b";
      base05 = "#cdcecf";
      base06 = "#aeafb0";
      base07 = "#e4e4e5";
      base08 = "#c94f6d";
      base09 = "#f4a261";
      base0A = "#dbc074";
      base0B = "#81b29a";
      base0C = "#63cdcf";
      base0D = "#719cd6";
      base0E = "#9d79d6";
      base0F = "#d67ad2";
    };
  };

  programs.looking-glass-client = {
    enable = true;
  };

  services.sunshine.enable = true;

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
    (writeShellScriptBin "toggle-vm" ''
      nets=$(virsh --connect qemu:///system net-list | grep default)
      running=$(virsh --connect qemu:///system list --all | grep running)
      if [[ -z "$nets" ]]; then
        echo "Starting network..."
        virsh --connect qemu:///system net-start default
      fi

      if [[ -z "$running" ]]; then
        virsh --connect qemu:///system start win11
      else
        virsh --connect qemu:///system shutdown win11
      fi
    '')
    (writeShellScriptBin "kvm-monitor" ''
      vms=($(virsh --connect qemu:///system list | grep -e "[0-9]\+"))
      n=''${#vms[@]}
      tooltip="Virtual Machines:"
      for vm in "''${vms[@]}";
      do
          tooltip="$tooltip\n$vm"
      done
      if [[ n -gt 0 ]]
      then
         echo "{\"class\": \"running\", \"text\": \"$n\", \"tooltip\": \"$tooltip\"}"
         exit
      fi
    '')
    (writeShellScriptBin "lock-monitor" ''
      state="/home/linus/.togglemonitorlock"
      booleanvalue="false"

      if [[ -f ''${state} ]]; then
           booleanvalue=$(cat ''${state})
      fi

      if [[ ''${booleanvalue} == "true" ]]; then
           ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,0
           echo "false" > ''${state}
      else
           ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,4000
           echo "true" > ''${state}
      fi
    '')
  ];

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config pkgs;})
    + ''
      monitor=DP-1,3440x1440@144,0x0,1
      monitor=DP-2,1920x1080@60,0x-1080,1
      monitor=DP-3,1920x1080@60,1920x-1080,1
      monitor=HDMI-A-1,3840x2160@120,3440x-1080,1

      workspace=1, monitor:DP-1, persistent:true
      workspace=2, monitor:DP-1, persistent:true
      workspace=3, monitor:DP-1, persistent:true
      workspace=4, monitor:DP-2, persistent:true
      workspace=5, monitor:DP-3, persistent:true

      # bind = $mainMod, 1, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers1.png}"
      # bind = $mainMod, 2, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers5.png}"
      # bind = $mainMod, 3, exec, hyprctl hyprpaper wallpaper "DP-1,${../secrets/wallpapers/flowers6.png}"
      bind = $mainMod,o,exec, swap-audio
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = DP-1,${../secrets/wallpapers/abstract1.jpg}
      wallpaper = DP-2,${../secrets/wallpapers/abstract1.jpg}
      wallpaper = DP-3,${../secrets/wallpapers/abstract1.jpg}
      wallpaper = HDMI-A-1,${../secrets/wallpapers/abstract1.jpg}
    '';
}
