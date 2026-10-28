{
  config,
  pkgs,
}: ''
  -- ============================================================
  -- Laptop-specific Hyprland Lua configuration
  -- ============================================================

  -- Monitors
  hl.monitor({ output = "eDP-1",    mode = "2880x1920@120", position = "0x0",   scale = 1.6 })

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
