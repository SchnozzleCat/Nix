''
monitor=DP-1,3440x1440@144,0x0,1
monitor=DP-2,1920x1080@60,0x-1080,1
monitor=DP-3,1920x1080@60,1920x-1080,1
monitor=HDMI-A-1,1920x1080@60,3440x-1080,1

workspace=DP-1,1
workspace=DP-1,2
workspace=DP-1,3
workspace=DP-2,4
workspace=DP-3,5

exec-once = waybar
exec-once = fnott
exec-once = swaybg -i /home/linus/.config/hypr/blobs-d.svg -m fill
exec-once = hyprctrl dispatch layoutmsg "preselect r"
exec-once = wl-paste -t text --watch clipman store --max-items 1024
exec-once = /home/linus/Downloads/MoonDeckBuddy-1.5.7-x86_64.AppImage
    
exec-once = systemctl --user start sunshine
exec-once = systemctl --user start app-nm\\x2dapplet@autostart.service
exec-once = systemctl --user start app-jetbrains\x2dtoolbox@autostart.service
exec-once = systemctl --user start app-sealertauto@autostart.service
exec-once = systemctl --user start app-solaar@autostart.service

exec-once = corectrl

exec-once=/usr/lib/polkit-1/polkit-agent-helper-1

env = XCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = WLR_NO_HARDWARE_CURSORS,1

windowrulev2=float,class:^(UnrealEditor)$
windowrulev2=unset,class:^(UnrealEditor)$,title:^\w*$
windowrulev2=noinitialfocus,class:^(UnrealEditor)$,title:^\w*$
windowrulev2=noanim,class:^(UnrealEditor)$,title:^\w*$

windowrulev2=windowdance,initialclass:^(Unity)$
windowrulev2=noinitialfocus,initialclass:^(Unity)$

windowrulev2=windowdance,initialclass:^(jetbrains-rider)$
windowrulev2=noinitialfocus,initialclass:^(jetbrains-rider)$

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us

    follow_mouse = 1
    kb_options = caps:escape
    accel_profile = flat
    sensitivity = 0

    repeat_delay = 250
    repeat_rate = 45

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

misc {
        key_press_enables_dpms = true
}

general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 4
    gaps_out = 5
    border_size = 1
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle

    cursor_inactive_timeout = 5
}

decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    blur {
        enabled = true
        size = 3
        passes = 1
        special = true
        xray = true
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 4, myBezier
    animation = windowsOut, 1, 4, default, popin 80%
    animation = border, 1, 5, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 4, default
    animation = specialWorkspace, 1, 4, default, fade
}

dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = yes # you probably want this
    #permanent_direction_override = true
}

master {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true
}

gestures {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = off
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
device:epic-mouse-v1 {
    sensitivity = -0.5
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


# See https://wiki.hyprland.org/Configuring/Keywords/ for more
$mainMod = SUPER

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, return, exec, foot
bind = $mainMod, d, exec, fuzzel
bind = $mainModSHIFT, Q, killactive, 
bind = $mainMod, s, togglegroup, # dwindle

bind = $mainMod, comma, exec, ~/.config/hypr/dec-brightness.sh
bind = $mainMod, period, exec, ~/.config/hypr/inc-brightness.sh

# Move focus with mainMod + arrow keys
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d # Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9
bind = $mainMod SHIFT, 0, movetoworkspacesilent, 10

binde = $mainMod SHIFT CTRL, h, resizeactive, -25 0
binde = $mainMod SHIFT CTRL, j, resizeactive, 0 -25
binde = $mainMod SHIFT CTRL, k, resizeactive, 0 25
binde = $mainMod SHIFT CTRL, l, resizeactive, 25 0

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

bind = $mainMod, f, fullscreen
bind = $mainMod SHIFT, space, togglefloating

bind = $mainMod SHIFT, h, swapwindow, l
bind = $mainMod SHIFT, j, swapwindow, d
bind = $mainMod SHIFT, k, swapwindow, u
bind = $mainMod SHIFT, l, swapwindow, r

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Umlauts
bind = $mainMod CTRL, o, exec, wtype ö
bind = $mainMod CTRL SHIFT, o, exec, wtype Ö
bind = $mainMod CTRL, u, exec, wtype ü
bind = $mainMod CTRL SHIFT, u, exec, wtype Ü
bind = $mainMod CTRL, a, exec, wtype ä
bind = $mainMod CTRL SHIFT, a, exec, wtype Ä

bind = $mainMod SHIFT, minus, movetoworkspacesilent, special
bind = $mainMod, minus, togglespecialworkspace


bind = $mainMod Shift, p, exec, slurp | grim -g - - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')
bind = $mainMod Shift Ctrl, p, exec, slurp | grim -g - - | swappy -f - -o - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim_annotated.png')
bind = $mainMod Shift,c,exec, ~/.config/hypr/hyprpicker | head -c 7 | wl-copy

bind = $mainMod, i, exec, swaylock -f
bind = $mainMod, n, exec, fnottctl dismiss
bind = $mainMod, c, exec, clipman pick --tool=CUSTOM --tool-args="fuzzel -d"
bind = $mainMod, XKB_KEY_semicolon, exec, BEMOJI_PICKER_CMD='fuzzel --dmenu' bemoji -t

bind = $mainMod,t, exec, ~/.config/sway/translate-en-to-de.sh
bind = $mainMod Shift,t, exec, ~/.config/sway/translate-de-to-en.sh
bind = $mainMod Ctrl Shift,t, exec, ~/.config/sway/synonym.sh

bind = $mainMod, p, exec, ~/.config/sway/bwmenu

bind = $mainMod,o,exec, ~/.config/sway/swap-audio.sh
bind = $mainMod Shift, v, exec, ~/.config/sway/looking-glass-client -F
bind = $mainMod Ctrl Shift,v, exec, ~/.config/sway/toggle-vm.sh

bind = $mainMod, b, exec, hyprctl dispatch layoutmsg "preselect r"
bind = $mainMod, v, exec, hyprctl dispatch layoutmsg "preselect d"

bind = $mainMod, q, exec, ~/.config/sway/power.sh

bind = $mainMod, w, exec, hyprctl activewindow | wl-copy

bind = $mainMod, m, exec, foot ranger
bind = $mainMod Shift,m, exec, ~/.config/sway/calc.sh
''