-- Foldout panel: details for every running pi coding-agent instance.
-- Opened by clicking the bar widget (linus/pi-instances:pi), via the
-- `pi-instances` command or the Hyprland SUPER+E bind (both count-aware:
-- they open this entry, `linus/pi-instances:instances`, when more than one
-- agent is running, and the compact `linus/pi-instances:instance` variant
-- for 0-1 -- panel sizes are manifest-fixed, so the size split is a second
-- entry, and both entries run this same script.
--
-- Panels do not honor noctalia.setUpdateInterval(); their update() only
-- ticks on panel.setWantsSecondTicks(true), a fixed 1 s repeating tick
-- that runs while the panel is open (and resets on reload, so it is
-- declared here at the top level). The root column also needs flexGrow so
-- the list's ui.scroll has height to grow into -- the panel reconciles
-- the tree into a content flex, and without it the column sizes to its
-- content height and the scroll collapses to one entry.

local instances = require("./lib/instances.luau")

panel.setWantsSecondTicks(true)

local open = false

local function dim(text)
  return ui.label({ text = text, fontSize = 12, color = "on_surface/0.7" })
end

--- How long the instance has been in its current state, e.g.
--- "working for 4m" / "waiting for input for 2m" / "done for 40s".
local function runtimeText(data)
  local stateword = "done"
  if data.state == "working" then
    stateword = "working"
  elseif data.state == "waiting_input" then
    stateword = "waiting for input"
  end
  local since = instances.ago(data.stateSinceEpoch)
  if since == "just now" then
    return stateword .. ", just started"
  end
  return stateword .. " for " .. since
end

local function instanceCard(data)
  local color = instances.stateColor(data)

  local footer = { "pid " .. tostring(data.pid) .. (data.sandboxed and " (bwrap jail)" or "") }
  if data.lastTool then
    table.insert(footer, "last tool: " .. tostring(data.lastTool))
  end

  local children = {
    ui.row({ gap = 8, align = "center" }, {
      ui.box({ key = "light", width = 8, height = 8, radius = 4, fill = color }),
      ui.label({ key = "name", text = instances.label(data), fontWeight = "bold", flexGrow = 1 }),
      ui.label({ key = "state", text = instances.stateText(data), color = color }),
    }),
  }
  -- Start of the last submitted prompt (truncated by the extension).
  if data.lastPrompt then
    table.insert(children, dim(tostring(data.lastPrompt)))
  end
  if data.activity then
    table.insert(children, dim(tostring(data.activity)))
  end
  if data.model then
    table.insert(children, dim(tostring(data.model)))
  end
  if data.cwd then
    table.insert(children, dim(tostring(data.cwd)))
  end
  table.insert(children, dim(runtimeText(data)))
  table.insert(children, dim(table.concat(footer, " \u{00b7}")))

  return ui.column({ key = "inst-" .. tostring(data.id), gap = 3 }, children)
end

local function render()
  local live = instances.load()

  local rows = {}
  if #live == 0 then
    table.insert(rows, dim("No pi instances are running."))
  else
    for _, data in ipairs(live) do
      table.insert(rows, instanceCard(data))
      table.insert(rows, ui.separator({ key = "sep-" .. tostring(data.id), spacing = 4 }))
    end
  end

  panel.render(ui.column({ key = "root", gap = 10, padding = 12, flexGrow = 1 }, {
    ui.row({ key = "header", gap = 8, align = "center" }, {
      ui.glyph({ key = "glyph", name = "robot", size = 16, color = "primary" }),
      ui.label({ key = "title", text = "pi instances", fontSize = 15, fontWeight = "bold", flexGrow = 1 }),
      ui.label({ key = "count", text = tostring(#live) .. " live", fontSize = 12, color = "on_surface/0.7" }),
      ui.button({ key = "close", glyph = "x", variant = "ghost", onClick = "onCloseClicked" }),
    }),
    ui.scroll({ key = "list", gap = 6, flexGrow = 1 }, rows),
  }))
end

function onOpen(_context)
  open = true
  render()
end

function onClose()
  open = false
end

function onCloseClicked()
  panel.close()
end

function update()
  -- 1 s tick while the panel is open (see setWantsSecondTicks above).
  if open then
    render()
  end
end
