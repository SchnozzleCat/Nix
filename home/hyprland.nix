{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    workspace = [
      "DP-1, 1"
      "DP-1, 2"
      "DP-1, 3"
      "DP-2, 4"
      "DP-3, 5"
    ];

    bind = [
      ''$mainMod, return, exec, foot''
      ''$mainMod, d, exec, fuzzel''
      ''$mainModSHIFT, Q, killactive, ''
      ''$mainMod, s, togglegroup, # dwindle''

      ''$mainMod, comma, exec, ~/.config/hypr/dec-brightness.sh''
      ''$mainMod, period, exec, ~/.config/hypr/inc-brightness.sh''

      ''$mainMod, h, movefocus, l''
      ''$mainMod, l, movefocus, r''
      ''$mainMod, k, movefocus, u''
      ''$mainMod, j, movefocus, d''
      map (i: ''$mainMod, ${toString i}, workspace, ${toString i}'') (builtins.range 1 9);
      ''$mainMod, 0, workspace, 10''

      map (i: ''$mainMod SHIFT, ${toString i}, movetoworkspacesilent, ${toString i}'') (builtins.range 1 9);
      ''$mainMod SHIFT, 0, movetoworkspacesilent, 10''

      ''$mainMod SHIFT CTRL, h, resizeactive, -25 0''
      ''$mainMod SHIFT CTRL, j, resizeactive, 0 -25''
      ''$mainMod SHIFT CTRL, k, resizeactive, 0 25''
      ''$mainMod SHIFT CTRL, l, resizeactive, 25 0''

      ''$mainMod, mouse_down, workspace, e+1''
      ''$mainMod, mouse_up, workspace, e-1''

      ''$mainMod, f, fullscreen''
      ''$mainMod SHIFT, space, togglefloating''

      ''$mainMod SHIFT, h, swapwindow, l''
      ''$mainMod SHIFT, j, swapwindow, d''
      ''$mainMod SHIFT, k, swapwindow, u''
      ''$mainMod SHIFT, l, swapwindow, r''

      ''$mainMod, mouse:272, movewindow''
      ''$mainMod, mouse:273, resizewindow''

      ''$mainMod CTRL, o, exec, wtype ö''
      ''$mainMod CTRL SHIFT, o, exec, wtype Ö''
      ''$mainMod CTRL, u, exec, wtype ü''
      ''$mainMod CTRL SHIFT, u, exec, wtype Ü''
      ''$mainMod CTRL, a, exec, wtype ä''
      ''$mainMod CTRL SHIFT, a, exec, wtype Ä''

      ''$mainMod SHIFT, minus, movetoworkspacesilent, special''
      ''$mainMod, minus, togglespecialworkspace''


      ''$mainMod Shift, p, exec, slurp | grim -g - - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')''
      ''$mainMod Shift Ctrl, p, exec, slurp | grim -g - - | swappy -f - -o - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim_annotated.png')''
      ''$mainMod Shift,c,exec, ~/.config/hypr/hyprpicker | head -c 7 | wl-copy''

      ''$mainMod, i, exec, swaylock -f''
      ''$mainMod, n, exec, fnottctl dismiss''
      ''$mainMod, c, exec, clipman pick --tool=CUSTOM --tool-args="fuzzel -d"''
      ''$mainMod, XKB_KEY_semicolon, exec, BEMOJI_PICKER_CMD='fuzzel --dmenu' bemoji -t''

      ''$mainMod,t, exec, ~/.config/sway/translate-en-to-de.sh''
      ''$mainMod Shift,t, exec, ~/.config/sway/translate-de-to-en.sh''
      ''$mainMod Ctrl Shift,t, exec, ~/.config/sway/synonym.sh''

      ''$mainMod, p, exec, ~/.config/sway/bwmenu''

      ''$mainMod,o,exec, ~/.config/sway/swap-audio.sh''
      ''$mainMod Shift, v, exec, ~/.config/sway/looking-glass-client -F''
      ''$mainMod Ctrl Shift,v, exec, ~/.config/sway/toggle-vm.sh''

      ''$mainMod, b, exec, hyprctl dispatch layoutmsg "preselect r"''
      ''$mainMod, v, exec, hyprctl dispatch layoutmsg "preselect d"''

      ''$mainMod, q, exec, ~/.config/sway/power.sh''

      ''$mainMod, w, exec, hyprctl activewindow | wl-copy''

      ''$mainMod, m, exec, foot ranger''
      ''$mainMod Shift,m, exec, ~/.config/sway/calc.sh''
    ];
  }
}
