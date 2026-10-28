{
  config,
  pkgs,
}: ''
  -- ============================================================
  -- Laptop-specific Hyprland Lua configuration
  -- ============================================================

  -- Monitors
  hl.monitor({ output = "eDP-1",    mode = "2880x1920@120", position = "0x0",   scale = 1.6 })

  -- --------------------------------------------------------
  -- HiDPI / Xwayland
  -- At a fractional 1.6 scale, Xwayland windows are upscaled by the
  -- compositor with nearest-neighbor, which looks very blurry, and the
  -- cursor buffer it exports is 1x. force_zero_scaling makes Hyprland
  -- hand Xwayland a scale-1 output: X apps render at native resolution
  -- (crisp) and scale themselves via the toolkit DPI vars below.
  -- --------------------------------------------------------
  hl.config({
    xwayland = {
      force_zero_scaling = true,
    },
  })

  -- Toolkit DPI for the X apps that no longer get compositor scaling.
  -- GDK_SCALE is integer-only; 2 combined with GDK_DPI_SCALE 0.8 nets 1.6.
  -- (Wayland-native GTK/Qt apps ignore GDK_* and take the real scale from
  -- the compositor, so these don't affect them.)
  hl.env("GDK_SCALE", "2")
  hl.env("GDK_DPI_SCALE", "0.8")
  hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
  hl.env("QT_SCREEN_SCALE_FACTORS", "eDP-1=1.6")
  -- Apps that ignore toolkit DPI (some Electron/X11-only apps) can be
  -- launched with e.g. --force-device-scale-factor=1.6.

  -- Empty submap for remote desktop
  hl.define_submap("empty", function()
    hl.bind(mainMod .. " + SHIFT + CTRL + o", hl.dsp.submap("reset"))
  end)

  -- Laptop-specific binds
  hl.bind(mainMod .. " + SHIFT + CTRL + o", hl.dsp.submap("empty"))
  hl.bind(mainMod .. " + e",      hl.dsp.exec_cmd("alacritty -e ssh 192.168.200.20 -p 6969"))
  hl.bind(mainMod .. " + SHIFT + e", hl.dsp.exec_cmd("remote-desktop"))
  -- power+i: noctalia lock screen. Overrides the shared config's mainMod+i
  -- -> hyprlock bind (this file is concatenated after it; hyprland resolves
  -- duplicate binds last-wins). The desktop keeps hyprlock.
  hl.bind(mainMod .. " + i",      hl.dsp.exec_cmd("noctalia msg session lock"))

  -- Laptop-specific misc options
  hl.config({
    misc = {
      key_press_enables_dpms = true,
      disable_hyprland_logo = true,
    },
  })
''
