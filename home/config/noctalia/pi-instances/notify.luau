-- Headless service: sends a desktop notification via notify-send when a
-- running pi agent stops working -- i.e. on the working -> <anything>
-- transition (done, or waiting for input).
--
--   title: "Agent: <working dir name>" (e.g. "Agent: .nixos")
--   body:  truncated last prompt, model, status -- one per line
--   both notifications expire after 5 seconds
--
-- Polls the same instance reports as the bar widget and the panel
-- (~/.cache/pi-instances/<uuid>.json) once per second and only notifies on
-- an observed transition -- an instance that is already stopped when the
-- service starts (e.g. Noctalia restarted mid-idle) or one that simply
-- disappears while working (the user closed pi) never fires.
--
-- Toggled with the plugin-level "notify_stop" setting (Settings ->
-- Plugins -> Pi Instances); changing it restarts this service.

local instances = require("./lib/instances.luau")

-- notify-send accepts an icon name or file path; prefer pi's real desktop
-- icon when one is installed (cache it -- appIconPath scans the fs).
local icon = nil
local function notifyIcon()
  if icon == nil then
    icon = noctalia.appIconPath("pi") or "utilities-terminal"
  end
  return icon
end

local function notify(data)
  local body = {}
  if data.lastPrompt then
    table.insert(body, tostring(data.lastPrompt))
  end
  if data.model then
    table.insert(body, tostring(data.model))
  end
  table.insert(body, instances.stateText(data))

  -- Argument-array form (plugin_api 24): dynamic labels need no shell quoting.
  noctalia.runAsync({
    "notify-send",
    "--app-name=pi",
    "--icon=" .. notifyIcon(),
    "--expire-time=5000",
    "Agent: " .. (data.cwd and instances.basename(data.cwd) or instances.label(data)),
    table.concat(body, "\n"),
  })
end

local previous = {} -- instance id -> last seen state

function update()
  noctalia.setUpdateInterval(1000)

  if noctalia.getConfig("notify_stop") == false then
    return
  end

  local live = instances.load()
  local seen = {}
  for _, data in ipairs(live) do
    local id = tostring(data.id)
    seen[id] = true
    if previous[id] == "working" and data.state ~= "working" then
      notify(data)
    end
    previous[id] = data.state
  end
  -- Forget instances that went away (closed or killed pi).
  for id in pairs(previous) do
    if not seen[id] then
      previous[id] = nil
    end
  end
end
