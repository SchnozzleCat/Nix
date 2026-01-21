{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  master,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 300;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  colorScheme = {
    name = "schnozzlecat";
    palette = {
      base00 = "#1D2228";
      base01 = "#161a1e";
      base02 = "#254365";
      base03 = "#414868";
      base04 = "#89BEFF";
      base05 = "#919BCA";
      base06 = "#a9b1d6";
      base07 = "#E7EAEE";
      base08 = "#F97791";
      base09 = "#FFA064";
      base0A = "#FFA064";
      base0B = "#38FFA5";
      base0C = "#5CCEFF";
      base0D = "#B1A2FF";
      base0E = "#FFB3EC";
      base0F = "#F73F64";
    };
  };

  home.packages = with pkgs; [
    wireguard-tools
    parsec-bin

    (writeShellApplication {
      name = "wake-desktop";
      text = ''${pkgs.wakeonlan}/bin/wakeonlan d8:5e:d3:8a:17:75'';
    })
    (writeShellApplication {
      name = "remote-desktop";
      text = ''hyprctl dispatch submap empty && hyprctl keyword monitor "eDP-1, 1920x1080@120, 0x0, 1" && ${pkgs.moonlight-embedded}/bin/moonlight stream 192.168.200.20 -app Desktop -1080 && hyprctl dispatch submap reset && hyprctl keyword monitor "eDP-1, 2880x1800@120, 0x0, 1.6"'';
    })
  ];

  wayland.windowManager.hyprland.extraConfig =
    (import ./hyprland.nix {inherit config pkgs;})
    + ''
      monitor=eDP-1,2880x1800@120,0x0,1.6
      monitor=HDMI-A-1,1920x1080@60,2880x0,1

      bind = $mainMod Shift Ctrl, o, submap, empty
      submap = empty
      bind = $mainMod Shift Ctrl, o, submap, reset
      submap = reset

      bind = $mainMod, e, exec, foot -- ssh 192.168.200.20 -p 6969
      bind = $mainMod Shift, e, exec, remote-desktop
      misc {
              key_press_enables_dpms = true
              disable_hyprland_logo = true
      }
    '';

  home.file.".config/hypr/hyprpaper.conf".text =
    (import ./hyprpaper.nix)
    + ''
      wallpaper = eDP-1,${../secrets/wallpapers/abstract1.jpg}
      wallpaper = HDMI-A-1,${../secrets/wallpapers/abstract1.jpg}
    '';
}
