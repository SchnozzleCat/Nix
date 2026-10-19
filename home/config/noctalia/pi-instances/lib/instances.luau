-- Shared helpers for the linus/pi-instances plugin entries. Loaded with
-- require() (plugin_api >= 22); entries are isolated VMs, so the widget and
-- the panel both pull their data through this module.
--
-- Reports are written per pi process by the pi extension
-- ~/.pi/agent/extensions/instance-report.ts (managed by home/linus.nix) as
-- ~/.cache/pi-instances/<uuid>.json.
--
-- Liveness: jailed pi processes run in an unshared PID namespace (their pid
-- is a namespace pid, e.g. 2), so /proc pid checks cannot work across the
-- jail boundary. The extension instead heartbeats every 20 s; a report is
-- live while its updatedAtEpoch is within TTL_SECONDS, and stale reports
-- (SIGKILLed instances) are garbage-collected on the way through.

local M = {}

M.STATE_DIR = "~/.cache/pi-instances"

-- How long a report stays live after its last heartbeat (heartbeat is 20 s).
M.TTL_SECONDS = 120

-- Status light colors (match the colorScheme in home/linus-desktop.nix).
M.COLOR = {
  done = "#a6e3a1", -- green  (base0B): finished, nothing pending
  working = "#f9e2af", -- yellow (base0A): agent loop is running
  waiting_input = "#f38ba8", -- red    (base08): blocked on the user
  none = "#585b70", -- gray   (base04): no live instance / unknown state
}

M.STATE_LABEL = {
  done = "done",
  working = "working",
  waiting_input = "waiting for input",
}

function M.label(data)
  return data.label or ("pi " .. tostring(data.pid))
end

--- Final path segment, e.g. "/home/linus/.nixos" -> ".nixos".
function M.basename(p)
  local name = string.match(tostring(p), "([^/]+)/?$")
  return name ~= nil and name ~= "" and name or tostring(p)
end

function M.stateColor(data)
  return M.COLOR[data.state] or M.COLOR.none
end

function M.stateText(data)
  return M.STATE_LABEL[data.state] or tostring(data.state or "?")
end

local function isLive(data)
  if type(data.updatedAtEpoch) ~= "number" then
    return false
  end
  return (os.time() - data.updatedAtEpoch) <= M.TTL_SECONDS
end

--- All live pi instances, oldest first (stable order for the bar cycle).
--- Stale reports (the pi process died, e.g. SIGKILL) are garbage-collected.
function M.load()
  local out = {}
  local dir = noctalia.expandPath(M.STATE_DIR)
  local names = noctalia.listDir(dir)
  if not names then
    return out
  end
  for _, name in ipairs(names) do
    if string.match(name, "%.json$") then
      local raw = noctalia.readFile(dir .. "/" .. name)
      local data = raw and noctalia.json.decode(raw)
      if type(data) == "table" and data.id ~= nil then
        if isLive(data) then
          table.insert(out, data)
        else
          -- The pi process is gone; drop its report.
          noctalia.removeFile(dir .. "/" .. name)
        end
      end
    end
  end
  table.sort(out, function(a, b)
    if a.startedAtEpoch == b.startedAtEpoch then
      return a.id < b.id
    end
    return a.startedAtEpoch < b.startedAtEpoch
  end)
  return out
end

--- "3m"-style age of a unix-seconds timestamp.
function M.ago(epoch)
  if type(epoch) ~= "number" then
    return ""
  end
  local s = os.time() - epoch
  if s < 0 then
    s = 0
  end
  if s < 60 then
    return "just now"
  elseif s < 3600 then
    return string.format("%dm", math.floor(s / 60))
  elseif s < 86400 then
    return string.format("%dh", math.floor(s / 3600))
  end
  return string.format("%dd", math.floor(s / 86400))
end

return M
