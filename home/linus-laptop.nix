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
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
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
      text = ''
        # Hyprland 0.55+ (Lua config): hyprctl dispatch evaluates a Lua expression
        # and hyprctl keyword is gone -> use hl.dsp.* / hl.monitor({ ... }) via eval.
        hyprctl dispatch 'hl.dsp.submap("empty")' \
          && hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "1920x1080@120", position = "0x0", scale = 1 })' \
          && ${pkgs.moonlight-embedded}/bin/moonlight stream 192.168.200.20 -app Desktop -1080 \
          && hyprctl dispatch 'hl.dsp.submap("reset")' \
          && hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "0x0", scale = 1.67 })'
      '';
    })
  ];

  wayland.windowManager.hyprland.extraConfig =
    import ./config/hyprland-laptop.lua.nix {inherit config pkgs;};
}
