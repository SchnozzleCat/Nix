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
      base00 = "#1e1e2e"; # base
      base01 = "#181825"; # mantle
      base02 = "#313244"; # surface0
      base03 = "#45475a"; # surface1
      base04 = "#585b70"; # surface2
      base05 = "#cdd6f4"; # text
      base06 = "#f5e0dc"; # rosewater
      base07 = "#b4befe"; # lavender
      base08 = "#f38ba8"; # red
      base09 = "#fab387"; # peach
      base0A = "#f9e2af"; # yellow
      base0B = "#a6e3a1"; # green
      base0C = "#94e2d5"; # teal
      base0D = "#89b4fa"; # blue
      base0E = "#cba6f7"; # mauve
      base0F = "#f2cdcd"; # flamingo
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

      bind = $mainMod,o,exec, swap-audio
      bind = $mainMod Shift,o,exec, hyprctl dispatch dpms off
      bind = $mainMod Ctrl Shift,o,exec, hyprctl dispatch dpms on

      misc {
              key_press_enables_dpms = false
              disable_hyprland_logo = true
      }
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
