{
  config,
  pkgs,
}: ''
  -- ============================================================
  -- Desktop-specific Hyprland Lua configuration
  -- ============================================================

  -- Monitors
  hl.monitor({ output = "DP-1",    mode = "3440x1440@144", position = "0x0",    scale = 1 })
  hl.monitor({ output = "DP-2",    mode = "1920x1080@60",  position = "0x-1080", scale = 1 })
  hl.monitor({ output = "DP-3",    mode = "1920x1080@60",  position = "1920x-1080", scale = 1 })
  hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "3440x0",  scale = 1 })

  -- Workspace rules
  hl.workspace_rule({ workspace = "1", monitor = "DP-1", persistent = true })
  hl.workspace_rule({ workspace = "2", monitor = "DP-1", persistent = true })
  hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })
  hl.workspace_rule({ workspace = "4", monitor = "DP-2", persistent = true })
  hl.workspace_rule({ workspace = "5", monitor = "DP-3", persistent = true })

  -- Desktop-specific binds
  hl.bind(mainMod .. " + o", hl.dsp.exec_cmd("swap-audio"))
  hl.bind(mainMod .. " + SHIFT + o",      hl.dsp.dpms({ action = "disable" }))
  hl.bind(mainMod .. " + CTRL + SHIFT + o", hl.dsp.dpms({ action = "enable" }))

  -- Desktop-specific misc options
  hl.config({
    misc = {
      key_press_enables_dpms = false,
      disable_hyprland_logo = true,
    },
  })
''
