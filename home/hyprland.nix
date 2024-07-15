{
  config,
  pkgs,
}: let
  colors = config.colorScheme.palette;
in ''
  $mainMod = SUPER

  workspace=name:special,gapsout:150

  exec-once = hyprctl setcursor Bibata-Modern-Classic 1
  exec-once = hyprpaper
  exec-once = ollama serve

  exec-once = ${pkgs.waybar}/bin/waybar
  exec-once = pypr
  exec-once = solaar --window=hide
  exec-once = ${pkgs.xwaylandvideobridge}/bin/xwaylandvideobridge
  exec-once = hyprctrl dispatch layoutmsg "preselect r"
  exec-once = wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --max-items 1024
  exec-once = /home/linus/Downloads/MoonDeckBuddy-1.5.7-x86_64.AppImage

  exec-once = systemctl --user start sunshine
  exec-once = systemctl --user start app-nm\\x2dapplet@autostart.service
  exec-once = systemctl --user start app-jetbrains\x2dtoolbox@autostart.service
  exec-once = systemctl --user start app-sealertauto@autostart.service
  exec-once = systemctl --user start app-solaar@autostart.service

  exec-once = corectrl

  env = XCURSOR_SIZE,24
  env = XCURSOR_THEME,Bibata-Modern-Classic
  env = XDG_CURRENT_DESKTOP,Hyprland
  env = XDG_SESSION_DESKTOP,Hyprland
  env = XDG_SESSION_TYPE,wayland
  env = WLR_NO_HARDWARE_CURSORS,1

  bind = $mainMod,g,exec,pypr toggle term
  windowrulev2=float,class:^(foot-float)$
  windowrulev2=size 75% 60%,class:^(foot-float)$
  windowrulev2=workspace special:scratch_term silent,class:^(foot-float)$
  windowrulev2=move 12% 200%,class:^(foot-float)$

  bind = $mainMod,S,exec,pypr toggle volume
  windowrulev2=float,class:^(pavucontrol)$
  windowrulev2=size 40% 90%,class:^(pavucontrol)$
  windowrulev2=workspace special:scratch_volume silent,class:^(pavucontrol)$
  windowrulev2=move 200% 5%,class:^(pavucontrol)$

  bind = $mainMod,m,exec,pypr toggle ncspot
  windowrulev2=float,class:^(foot-ncspot)$
  windowrulev2=size 40% 90%,class:^(foot-ncspot)$
  windowrulev2=workspace special:scratch_volume silent,class:^(foot-ncspot)$
  windowrulev2=move 200% 5%,class:^(foot-ncspot)$

  windowrulev2 = stayfocused, title:^()$,class:^(steam)$
  windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$

  windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
  windowrulev2 = noanim,class:^(xwaylandvideobridge)$
  windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
  windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$

  windowrulev2=float,class:^(UnrealEditor)$
  windowrulev2=unset,class:^(UnrealEditor)$,title:^\w*$
  windowrulev2=noinitialfocus,class:^(UnrealEditor)$,title:^\w*$
  windowrulev2=noanim,class:^(UnrealEditor)$,title:^\w*$

  windowrulev2=windowdance,initialclass:^(Unity)$
  windowrulev2=noinitialfocus,initialclass:^(Unity)$

  windowrulev2=windowdance,initialclass:^(jetbrains-rider)$
  windowrulev2=noinitialfocus,initialclass:^(jetbrains-rider)$

  bind = $mainMod, Z, pin

  # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
  input {
      kb_layout = us
      kb_variant = altgr-intl

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
          disable_hyprland_logo = true
  }

  general {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 4
      gaps_out = 5
      border_size = 1
      col.active_border = rgba(ff00d0ee) rgba(00ff99ee) 45deg
      col.inactive_border = rgba(595959aa)

      layout = dwindle
  }

  cursor {
      inactive_timeout = 5
      enable_hyprcursor = true

  }

  decoration {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      blur {
          enabled = true
          size = 7
          passes = 3
          special = true
          xray = true
      }

      rounding = 5
      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
  }

  # layerrule = blur, waybar
  layerrule = blur, launcher
  layerrule = xray on, launcher

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
      new_status = master
  }

  gestures {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = off
  }

  # Example windowrule v1
  # windowrule = float, ^(kitty)$
  # Example windowrule v2
  # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


  # See https://wiki.hyprland.org/Configuring/Keywords/ for more

  # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
  bind = $mainMod, a, exec, foot
  bind = $mainMod, d, exec, fuzzel
  bind = $mainModSHIFT, Q, killactive,
  bind = $mainMod, b, exec, pypr expose
  bind = $mainModSHIFT, b, exec, lock-monitor
  bind = $mainMod, y, exec, ${pkgs.wl-mirror}/bin/wl-mirror --scaling cover --fullscreen DP-1
  bind = $mainModShift, y, exec, ${pkgs.wl-mirror}/bin/wl-mirror --fullscreen DP-1

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

  bind = $mainMod SHIFT, minus, movetoworkspacesilent, special
  bind = $mainMod, minus, togglespecialworkspace


  bind = $mainMod, p, exec, ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')
  bind = $mainMod Shift, p, exec, ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.swappy}/bin/swappy -f - -o - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim_annotated.png')
  bind = $mainMod Shift Ctrl, p, exec, record-screen

  bind = $mainMod Shift,c,exec, ${pkgs.hyprpicker}/bin/hyprpicker | head -c 7 | wl-copy

  bind = $mainMod, i, exec, ${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 9x7 --effect-vignette 0.5:0.5 --ring-color ${colors.base00}ff --key-hl-color ${colors.base0C}ff --line-color 00000000 --inside-color 00000088 --separator-color ${colors.base02}ff --text-color ${colors.base05}ff --grace 1 --fade-in 0.2

  bind = $mainMod, u, exec, fnottctl dismiss
  bind = $mainMod, c, exec, ${pkgs.clipman}/bin/clipman pick --tool=CUSTOM --tool-args="fuzzel -d"
  bind = $mainMod, XKB_KEY_semicolon, exec, BEMOJI_PICKER_CMD='fuzzel --dmenu' ${pkgs.bemoji}/bin/bemoji -t

  bind = $mainMod,t, exec, translate-en-to-de
  bind = $mainMod Shift,t, exec, translate-de-to-en
  bind = $mainMod Ctrl Shift,t, exec, synonym


  bind = $mainMod Shift, v, exec, ${pkgs.looking-glass-client}/bin/looking-glass-client -F
  bind = $mainMod Ctrl Shift,v, exec, toggle-vm

  bind = $mainMod, b, exec, hyprctl dispatch layoutmsg "preselect r"
  bind = $mainMod, v, exec, hyprctl dispatch layoutmsg "preselect d"

  bind = $mainMod Ctrl Shift, q, exec, power-menu
  bind = $mainMod, q, exec,  echo "" | fuzzel --dmenu --dmenu --prompt="Ask: " --lines=0 --width=125 | ollama run mistral | pipe-notify

  bind = $mainMod, w, exec, hyprctl activewindow | wl-copy

  bind = $mainMod, n, exec, [float;size 60% 60%;center] foot lf
  bind = $mainMod Shift,m, exec, ~/.config/sway/calc.sh
''
