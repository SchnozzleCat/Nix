-- Bar widget: shows an icon while the win11 VM is running, hidden otherwise.
-- Left-click runs the `toggle-vm` helper (see home/linus-desktop.nix).

local VM = "win11"

local function render(state)
  if state == "running" then
    barWidget.setVisible(true)
    barWidget.setGlyph("server")
    barWidget.setTooltip(VM .. " running (click to shut down)")
  else
    -- Hidden while the VM is off. If you'd rather always show the icon,
    -- comment out setVisible and uncomment the two lines below.
    barWidget.setVisible(false)
    -- barWidget.setGlyph("server-off")
    -- barWidget.setTooltip(VM .. " not running (click to start)")
  end
end

function update()
  noctalia.setUpdateInterval(5000)
  noctalia.runAsync({ "virsh", "--connect", "qemu:///system", "domstate", VM }, function(res)
    if res.exitCode == 0 then
      render(noctalia.string.trim(res.stdout))
    else
      render(nil)
    end
  end)
end

function onClick()
  noctalia.runAsync("toggle-vm")
end
