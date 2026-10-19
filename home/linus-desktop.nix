{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  master,
  nix-colors,
  ...
}: {
  imports = [
    ./linus.nix
  ];

  colorScheme = {
    slug = "schnozzlecat";
    name = "schnozzlecat";
    palette = {
      base00 = "#1e1e2e"; # base
      base01 = "#181825"; # mantle
      base02 = "#313244"; # surface0
      base03 = "#45475a"; # surface1
      base04 = "#585b70"; # surface2
      base05 = "#cdd6f4"; # text
      base06 = "#f5e0dc"; # rosewater
      base07 = "#b4befe"; # lavender
      base08 = "#f38ba8"; # red
      base09 = "#fab387"; # peach
      base0A = "#f9e2af"; # yellow
      base0B = "#a6e3a1"; # green
      base0C = "#94e2d5"; # teal
      base0D = "#89b4fa"; # blue
      base0E = "#cba6f7"; # mauve
      base0F = "#f2cdcd"; # flamingo
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Noctalia bar widget plugin: shows when the win11 VM is running.
  # Placed under ~/.local/share/noctalia/plugins/ -- Noctalia discovers this
  # as its built-in "local" plugin source. Enable it once with:
  #   noctalia msg plugins enable linus/vm-status
  # then add the widget to the bar (type "linus/vm-status:vm").
  xdg.dataFile."noctalia/plugins/vm-status/plugin.toml".source =
    ./config/noctalia/vm-status/plugin.toml;
  xdg.dataFile."noctalia/plugins/vm-status/widget.luau".source =
    ./config/noctalia/vm-status/widget.luau;

  # Noctalia bar widget + foldout panel: live status of all running pi
  # coding-agent instances (green = done, yellow = working, red = waiting
  # for input). Fed by ~/.pi/agent/extensions/instance-report.ts (see
  # home/linus.nix), which reports to ~/.cache/pi-instances/<uuid>.json.
  # A headless service entry also sends a notify-send desktop notification
  # when an agent stops working (finished or waiting for input; toggle:
  # "notify_stop" plugin setting).
  # Same "local" plugin source as vm-status. Enable once with:
  #   noctalia msg plugins enable linus/pi-instances
  # then add the widget to the bar (type "linus/pi-instances:pi"). The
  # panel folds out on widget click, via the `pi-instances` command, or
  #   noctalia msg panel-toggle linus/pi-instances:instances
  xdg.dataFile."noctalia/plugins/pi-instances/plugin.toml".source =
    ./config/noctalia/pi-instances/plugin.toml;
  xdg.dataFile."noctalia/plugins/pi-instances/widget.luau".source =
    ./config/noctalia/pi-instances/widget.luau;
  xdg.dataFile."noctalia/plugins/pi-instances/panel.luau".source =
    ./config/noctalia/pi-instances/panel.luau;
  xdg.dataFile."noctalia/plugins/pi-instances/notify.luau".source =
    ./config/noctalia/pi-instances/notify.luau;
  xdg.dataFile."noctalia/plugins/pi-instances/lib/instances.luau".source =
    ./config/noctalia/pi-instances/lib/instances.luau;
  xdg.dataFile."noctalia/plugins/pi-instances/translations/en.json".source =
    ./config/noctalia/pi-instances/translations/en.json;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-aitum-multistream
      obs-vertical-canvas
    ];
  };

  home.packages = with pkgs; [
    (writeShellApplication {
      name = "swap-audio";
      text = ''
        #!/bin/bash
        sink=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)
        if [[ $sink == "alsa_output.pci-0000_00_1f.3.analog-stereo" ]]; then
          ${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.usb-C-Media_Electronics_Inc._USB_Multimedia_Audio_Device-00.analog-stereo
        else
          ${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
        fi
      '';
    })
    (writeShellScriptBin "toggle-vm" ''
      nets=$(virsh --connect qemu:///system net-list | grep default)
      running=$(virsh --connect qemu:///system list --all | grep running)
      if [[ -z "$nets" ]]; then
        echo "Starting network..."
        virsh --connect qemu:///system net-start default
      fi

      if [[ -z "$running" ]]; then
        virsh --connect qemu:///system start win11
      else
        virsh --connect qemu:///system shutdown win11
      fi
    '')
    (writeShellScriptBin "kvm-monitor" ''
      vms=($(virsh --connect qemu:///system list | grep -e "[0-9]\+"))
      n=''${#vms[@]}
      tooltip="Virtual Machines:"
      for vm in "''${vms[@]}";
      do
          tooltip="$tooltip\n$vm"
      done
      if [[ n -gt 0 ]]
      then
         echo "{\"class\": \"running\", \"text\": \"$n\", \"tooltip\": \"$tooltip\"}"
         exit
      fi
    '')
    (writeShellScriptBin "lock-monitor" ''
      state="/home/linus/.togglemonitorlock"
      booleanvalue="false"

      if [[ -f ''${state} ]]; then
           booleanvalue=$(cat ''${state})
      fi

      if [[ ''${booleanvalue} == "true" ]]; then
           ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,0
           echo "false" > ''${state}
      else
           ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,4000
           echo "true" > ''${state}
      fi
    '')
    # Open the Noctalia "linus/pi-instances" foldout (see the plugin files
    # above); `--list` prints the live per-instance reports to the terminal
    # instead (same data the panel shows, straight from
    # ~/.cache/pi-instances/<uuid>.json). Liveness is the extension's
    # heartbeat (updatedAtEpoch within 120 s) -- jailed pi runs in an
    # unshared PID namespace, so /proc pid checks cannot work for it.
    (writeShellScriptBin "pi-instances" ''
      dir="''${XDG_CACHE_HOME:-$HOME/.cache}/pi-instances"

      if [[ "$1" == "--list" || "$1" == "-l" ]]; then
        found=0
        now=$(date +%s)
        for f in "$dir"/*.json; do
          [[ -e "$f" ]] || continue
          if command -v jq >/dev/null 2>&1; then
            age=$((now - $(jq -r '.updatedAtEpoch // 0' "$f")))
            [[ "$age" -le 120 ]] || continue
            jq -r '[.label // "pi", .state // "?", .model // "-", ((.pid|tostring) + (if .sandboxed then " (jailed)" else "" end))] | @tsv' "$f"
          else
            echo "--- $f ---"; cat "$f"
          fi
          found=1
        done
        [[ "$found" == 1 ]] || echo "no pi instances running"
      else
        # Open the compact panel (linus/pi-instances:instance) when at most
        # one agent is running, the full-size one otherwise -- panel sizes
        # are manifest-fixed, so the toggle picks the entry by live count
        # (same heartbeat-TTL liveness check as --list).
        target="linus/pi-instances:instances"
        if command -v jq >/dev/null 2>&1; then
          now=$(date +%s)
          count=0
          for f in "$dir"/*.json; do
            [[ -e "$f" ]] || continue
            age=$((now - $(jq -r '.updatedAtEpoch // 0' "$f")))
            [[ "$age" -le 120 ]] && count=$((count + 1))
          done
          [[ "$count" -le 1 ]] && target="linus/pi-instances:instance"
        fi
        exec noctalia msg panel-toggle "$target"
      fi
    '')
  ];

  wayland.windowManager.hyprland.extraConfig =
    import ./config/hyprland-desktop.lua.nix {inherit config pkgs;};
}
