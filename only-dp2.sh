#!/usr/bin/env bash
# Temporarily disable every monitor except DP-2 (Hyprland, Lua config).
# Press Enter or Ctrl-C to restore; `hyprctl reload` re-applies the config.
keep="${1:-DP-2}"

restore() {
  hyprctl reload
  exit 0
}
trap restore INT TERM

for m in $(hyprctl monitors all | awk '/^Monitor/ {print $2}'); do
  [ "$m" = "$keep" ] && continue
  hyprctl eval "hl.monitor({ output = '$m', disabled = true })"
done

read -rp "Only $keep active. Press Enter to restore all monitors..."
restore
