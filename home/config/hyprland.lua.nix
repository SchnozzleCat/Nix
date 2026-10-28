{
  config,
  pkgs,
}: let
  mainMod = "SUPER";
in ''
  -- ============================================================
  -- Hyprland Lua configuration
  -- Converted from the previous hyprlang config.
  -- See https://wiki.hypr.land/Configuring/Start/
  -- ============================================================

  local mainMod = "${mainMod}"

  -- --------------------------------------------------------
  -- Autostart
  -- --------------------------------------------------------
  hl.on("hyprland.start", function()
    -- Trailing arg is the BASE cursor size (px). Hyprland multiplies it by
    -- the monitor scale itself (CursorManager::updateTheme: style size =
    -- m_size * monitor-scale), so this must stay 24 -- a "1" here rendered
    -- a ~2px cursor on the laptop's scaled output.
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("pypr")
    hl.exec_cmd("solaar --window=hide")
    hl.exec_cmd("hyprctl dispatch layoutmsg \"preselect r\"")
    hl.exec_cmd("corectrl --minimize-systray")
  end)

  -- --------------------------------------------------------
  -- Environment variables
  -- --------------------------------------------------------
  hl.env("XCURSOR_SIZE", "24")
  -- Also pin the hyprcursor base size: with cursor:enable_hyprcursor,
  -- Hyprland's own cursor reads HYPRCURSOR_SIZE (XCURSOR_SIZE is only used
  -- when it falls back to plain X cursors).
  hl.env("HYPRCURSOR_SIZE", "18")
  hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
  hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
  hl.env("XDG_SESSION_DESKTOP", "Hyprland")
  hl.env("XDG_SESSION_TYPE", "wayland")
  hl.env("WLR_NO_HARDWARE_CURSORS", "1")

  -- --------------------------------------------------------
  -- Workspace rules
  -- --------------------------------------------------------
  hl.workspace_rule({ workspace = "name:special", gaps_out = 150 })

  -- --------------------------------------------------------
  -- Window rules
  -- --------------------------------------------------------
  hl.window_rule({
    name = "special:scratch_term",
    match = { class = "terminal-float" },
    float = true,
    size = { "monitor_w * 0.75", "monitor_h * 0.30" },
    move = { "monitor_w * 0.12", "monitor_h * 2.00" },
  })

  hl.window_rule({
    name = "special:pwvucontrol",
    match = { class = "com.saivert.pwvucontrol" },
    float = true,
  })

  -- LemonBattery is known at map time; a static rule floats it before the
  -- layout places it (no flash). Everything else is handled by the hook below.
  hl.window_rule({
    name = "godot-game-lemonbattery",
    match = { initial_class = "LemonBattery" },
    float = true,
  })

  -- Float all Godot game windows, not just LemonBattery.
  -- Godot sets the game window's app_id/WM_CLASS to the project name, so a
  -- static window rule can't match all games generically. Instead, on every
  -- new window check the process behind it and float godot game processes,
  -- excluding the editor (class "Godot" on X11) and project manager
  -- (org.godotengine.Editor / .ProjectManager on native Wayland). Dialog
  -- windows spawned by the editor keep the editor class and stay tiled.
  hl.on("window.open", function(win)
    local cls = (win.initial_class or ""):lower()

    -- Editor / project manager windows: leave tiled.
    if cls == "godot" or cls == "org.godotengine.editor" or cls == "org.godotengine.projectmanager" then
      return
    end

    local pid = win.pid
    if not pid or pid <= 0 then
      return
    end

    local f = io.open("/proc/" .. pid .. "/comm", "r")
    if not f then
      return
    end
    local comm = f:read("l") or ""
    f:close()

    if comm:lower():find("godot", 1, true) then
      hl.dispatch(hl.dsp.window.float({ action = "enable", window = win }))
    end
  end)

  hl.window_rule({
    name = "special:scratch_volume",
    match = { class = "pwvucontrol" },
    float = true,
    size = { "monitor_w * 0.40", "monitor_h * 0.90" },
    move = { "monitor_w * 2.00", "monitor_h * 0.05" },
  })

  -- --------------------------------------------------------
  -- Layer rules
  -- --------------------------------------------------------
  hl.layer_rule({ match = { namespace = "launcher" }, blur = true })
  hl.layer_rule({ match = { namespace = "launcher" }, xray = true })

  -- --------------------------------------------------------
  -- Input
  -- --------------------------------------------------------
  hl.config({
    input = {
      kb_layout = "us",
      kb_variant = "altgr-intl",
      follow_mouse = 1,
      kb_options = "caps:escape",
      accel_profile = "flat",
      sensitivity = 0,
      repeat_delay = 250,
      repeat_rate = 45,
      touchpad = {
        natural_scroll = false,
      },
    },
  })

  -- --------------------------------------------------------
  -- General appearance
  -- --------------------------------------------------------
  hl.config({
    general = {
      gaps_in = 4,
      gaps_out = 5,
      border_size = 1,
      col = {
        active_border = "rgba(94E2D5ee)",
        inactive_border = "rgba(1E1E2Eee)",
      },
      layout = "dwindle",
    },
  })

  -- --------------------------------------------------------
  -- Cursor
  -- --------------------------------------------------------
  hl.config({
    cursor = {
      inactive_timeout = 5,
      enable_hyprcursor = true,
    },
  })

  -- --------------------------------------------------------
  -- Decoration
  -- --------------------------------------------------------
  hl.config({
    decoration = {
      blur = {
        enabled = true,
        size = 8,
        passes = 3,
        special = true,
        xray = true,
      },
      rounding = 5,
    },
  })

  -- --------------------------------------------------------
  -- Animations
  -- --------------------------------------------------------
  hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

  hl.animation({ leaf = "windows",          enabled = true, speed = 4, bezier = "myBezier" })
  hl.animation({ leaf = "windowsOut",       enabled = true, speed = 4, bezier = "default", style = "popin 80%" })
  hl.animation({ leaf = "border",           enabled = true, speed = 5, bezier = "default" })
  hl.animation({ leaf = "borderangle",      enabled = true, speed = 8, bezier = "default" })
  hl.animation({ leaf = "fade",             enabled = true, speed = 7, bezier = "default" })
  hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "default" })
  hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "default", style = "fade" })

  -- --------------------------------------------------------
  -- Gestures
  -- --------------------------------------------------------
  -- 3-finger horizontal swipe to switch workspaces (touchpad)
  hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

  -- 3-finger pinch: out = make bigger (fullscreen), in = make smaller (float)
  hl.gesture({ fingers = 3, direction = "pinchout",  action = "float" })
  hl.gesture({ fingers = 3, direction = "pinchin", action = "fullscreen" })

  -- 3-finger vertical swipe: up = launcher, down = control center
  hl.gesture({ fingers = 3, direction = "up",   action = function() hl.exec_cmd("noctalia msg panel-toggle launcher") end })
  hl.gesture({ fingers = 3, direction = "down", action = function() hl.exec_cmd("noctalia msg panel-toggle control-center") end })

  -- --------------------------------------------------------
  -- Layouts
  -- --------------------------------------------------------
  hl.config({
    dwindle = {
      preserve_split = true,
    },
  })

  hl.config({
    master = {
      new_status = "master",
    },
  })

  -- --------------------------------------------------------
  -- Debug / Misc
  -- --------------------------------------------------------
  hl.config({
    debug = {
      full_cm_proto = true,
    },
  })

  hl.config({
    misc = {
      enable_anr_dialog = false,
    },
  })

  -- --------------------------------------------------------
  -- Keybinds
  -- --------------------------------------------------------

  -- Scratchpads
  hl.bind(mainMod .. " + w", hl.dsp.exec_cmd("pypr toggle term"))
  hl.bind(mainMod .. " + s", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center audio"))

  -- Window management
  hl.bind(mainMod .. " + Z", hl.dsp.window.pin())
  hl.bind(mainMod .. " + a", hl.dsp.exec_cmd("alacritty -e zellij"))
  hl.bind(mainMod .. " + SHIFT + a", hl.dsp.exec_cmd("alacritty"))
  hl.bind(mainMod .. " + n", hl.dsp.exec_cmd("alacritty -e ${pkgs.master.yazi}/bin/yazi", {
    float = true,
    size = { "monitor_w * 0.60", "monitor_h * 0.60" },
    center = true,
  }))
  hl.bind(mainMod .. " + z", hl.dsp.exec_cmd("alacritty -e ${pkgs.master.yazi}/bin/yazi", {
    float = true,
    size = { "monitor_w * 0.60", "monitor_h * 0.60" },
    center = true,
  }))
  hl.bind(mainMod .. " + d", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
  hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + SHIFT + b", hl.dsp.exec_cmd("lock-monitor"))
  hl.bind(mainMod .. " + y", hl.dsp.exec_cmd("${pkgs.wl-mirror}/bin/wl-mirror --scaling cover --fullscreen DP-1"))
  hl.bind(mainMod .. " + SHIFT + y", hl.dsp.exec_cmd("${pkgs.wl-mirror}/bin/wl-mirror --fullscreen DP-1"))

  -- Looking Glass
  hl.bind(mainMod .. " + v", hl.dsp.exec_cmd("looking-glass-client"))
  -- Start/stop the win11 VM (toggle-vm script from linus-desktop.nix)
  hl.bind(mainMod .. " + SHIFT + v", hl.dsp.exec_cmd("toggle-vm"))

  -- Media controls
  hl.bind(mainMod .. " + code:21", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl -a next"))
  hl.bind(mainMod .. " + code:48", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl -a previous"))

  -- Focus movement
  hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
  hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
  hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
  hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

  -- Workspaces
  for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
  end

  -- Resize
  hl.bind(mainMod .. " + SHIFT + CTRL + h", hl.dsp.window.resize({ x = -25, y = 0,  relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + CTRL + j", hl.dsp.window.resize({ x = 0,  y = -25, relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + CTRL + k", hl.dsp.window.resize({ x = 0,  y = 25,  relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + CTRL + l", hl.dsp.window.resize({ x = 25, y = 0,   relative = true }), { repeating = true })

  -- Window state
  hl.bind(mainMod .. " + f",            hl.dsp.window.fullscreen())
  hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))

  -- Swap windows
  hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "l" }))
  hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "d" }))
  hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "u" }))
  hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "r" }))

  -- Mouse binds
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  -- Special workspace
  hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special", follow = false }))
  hl.bind(mainMod .. " + minus",         hl.dsp.workspace.toggle_special(""))

  -- Screenshots / recording
  hl.bind(mainMod .. " + p",              hl.dsp.exec_cmd("${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')"))
  hl.bind(mainMod .. " + SHIFT + p",      hl.dsp.exec_cmd("${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.swappy}/bin/swappy -f - -o - | wl-copy && wl-paste > ~/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim_annotated.png')"))
  hl.bind(mainMod .. " + SHIFT + CTRL + p", hl.dsp.exec_cmd("record-screen"))

  -- Color picker
  hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd("${pkgs.hyprpicker}/bin/hyprpicker | head -c 7 | wl-copy"))

  -- Lock / notifications / clipboard / emoji
  hl.bind(mainMod .. " + i", hl.dsp.exec_cmd("${pkgs.hyprlock}/bin/hyprlock"))
  hl.bind(mainMod .. " + u", hl.dsp.exec_cmd("noctalia msg notification-clear-active"))
  hl.bind(mainMod .. " + c", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))

  -- Power menu
  hl.bind(mainMod .. " + CTRL + SHIFT + q", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))

  -- OBS LemonBattery scene switching on active window change
  hl.on("window.active", function(win, focusReason)
    local title = win.title or ""

    local key
    if title:match("Schnozzle%.LemonBattery") then
      key = "F8"
    elseif title:match("LemonBattery %(DEBUG%)") then
      key = "F10"
    elseif title:match("LemonBattery") then
      key = "F9"
    else
      key = "F9"
    end

    hl.dispatch(hl.dsp.send_shortcut({
      mods   = "",
      key    = key,
      window = "class:^(com.obsproject.Studio)$",
    }))
  end)
''
