-- Bar widget: live status of all running pi coding-agent instances.
--
-- Refreshes once per second, so state-light changes show immediately; it
-- advances to the next agent only every "cycle_seconds" (default 5 s):
--   green  = done               yellow = working
--   red    = waiting for input
-- Left-click toggles the details foldout panel (linus/pi-instances:instances).
-- The tooltip always lists every live instance.

local instances = require("./lib/instances.luau")

local PANEL_MULTI = "linus/pi-instances:instances"
local PANEL_SOLO = "linus/pi-instances:instance" -- compact, see plugin.toml

local REFRESH_MS = 1000

local cycle = 0
local lastAdvanceMs = 0
local cycleSeconds = tonumber(noctalia.getConfig("cycle_seconds")) or 5

local function light(color)
  return ui.box({ key = "light", width = 8, height = 8, radius = 4, fill = color })
end

local function renderRow(color, glyph, label, count)
  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = 6, align = "center" }, {
    light(color),
    ui.glyph({ key = "glyph", name = glyph, size = 14 }),
    ui.label({ key = "label", text = label, fontWeight = "bold" }),
    ui.label({ key = "count", text = count, opacity = 0.7 }),
  }))
end

local function renderTooltip(list)
  if #list == 0 then
    barWidget.setTooltip("No pi agents running (click to open details)")
    return
  end
  local rows = {}
  for _, data in ipairs(list) do
    local value = instances.stateText(data)
    if data.activity then
      value = value .. " \u{00b7} " .. tostring(data.activity)
    end
    table.insert(rows, { key = instances.label(data), value = value })
  end
  barWidget.setTooltip(rows)
end

function update()
  noctalia.setUpdateInterval(REFRESH_MS)

  local live = instances.load()

  if #live == 0 then
    renderRow(instances.COLOR.none, "robot-off", "0", "")
    renderTooltip(live)
    return
  end

  -- Re-render every second, but advance the cycle only every cycleSeconds.
  local nowMs = noctalia.nowMs()
  if nowMs - lastAdvanceMs >= cycleSeconds * 1000 then
    lastAdvanceMs = nowMs
    cycle = cycle + 1
  end
  local index = ((cycle - 1) % #live) + 1
  local data = live[index]

  renderRow(
    instances.stateColor(data),
    "robot",
    instances.label(data),
    string.format("%d/%d", index, #live)
  )
  renderTooltip(live)
end

function onClick()
  -- Pick the panel size for the current instance count at click time:
  -- the compact "instance" entry for 0-1 live agents, the full
  -- "instances" entry for more (panel sizes are manifest-fixed).
  local live = instances.load()
  noctalia.togglePanel(#live <= 1 and PANEL_SOLO or PANEL_MULTI)
end

function onRightClick()
  -- Force a re-read without waiting for the next second tick.
  update()
end
