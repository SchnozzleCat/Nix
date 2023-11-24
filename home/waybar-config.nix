{
  mainBar = {
    id = "top";
    height = 0;
    margin = "0px 5px 0p 0px";
    name = "top";
    layer = "top";
    position = "top";
    modules-right = ["clock" "pulseaudio" "backlight" "battery" "tray"];
    modules-center = ["hyprland/workspaces"];
    modules-left = ["disk" "memory" "cpu" "temperature" "custom/gpu-temperature" "custom/containers" "custom/vm" "custom/vpn" "sway/scratchpad"];
    "hyprland/workspaces" = {
    };

    "clock" = {
      format = "{:%a %d %b %H:%M}";
      tooltip = true;
    };

    "clock#utc" = {
      format = "{=%H=%M UTC}";
      timezone = "Etc/UTC";
    };

    "temperature" = {
      thermal-zone = 0;
      format = "󱃃 {temperatureC}°C";
    };

    "custom/gpu-temperature" = {
      format = "{}";
      interval = 10;
      exec = "sensors amdgpu-pci-0300 | grep junction | awk '{print substr($2,2)}' | sed 's/\\\.0//g' | sed 's/^/󰎓 /'";
    };
    "battery" = {
      format = "{icon} {capacity}%";
      format-alt = "{time}  {icon} {capacity}%";
      tooltip-format = "{time}";
      format-alt-click = "click-right";
      format-icons = ["" "" "" ""];
      format-charging = "";
      interval = 30;
      states = {
        warning = 50;
        critical = 20;
      };
    };
    "backlight" = {
      device = "intel_backlight";
      format = "{icon}";
      format-icons = ["" "" ""];
      on-scroll-up = "exec brightnessctl set 5%+";
      on-scroll-down = "brightnessctl set 5%-";
      states = {
        low = 0;
        mid = 50;
        high = 75;
      };
      smooth-scrolling-threshold = 1.0;
    };

    "pulseaudio" = {
      format = "{icon}";
      format-alt-click = "click-right";
      format-bluetooth = "";
      format-muted = "婢";
      format-icons = {
        headphone = "";
        default = ["" "" ""];
      };
      tooltip-format = "{volume}";
      scroll-step = 10;
      states = {
        low = 0;
        mid = 50;
        high = 75;
      };
      smooth-scrolling-threshold = 1.0;
    };
    "cpu" = {
      interval = 10;
      format = "  {usage}%";
      format-alt-click = "click-right";
      states = {
        low = 0;
        mid = 25;
        high = 50;
      };
    };
    "memory" = {
      interval = 30;
      format = "  {used:0.1f}G  {total:0.1f}G";
      tooltip-format = ''{used:0.1f}G used\n{avail:0.1f}G available\n{total:0.1f}G total'';
      format-alt-click = "click-right";
      states = {
        low = 0;
        mid = 50;
        high = 75;
      };
    };
    "disk" = {
      interval = 30;
      format = "󱛟 {used}  {free}";
      format-alt-click = "click-right";
      tooltip-format = "{used} used\n{free} free\n{total} total";
      path = "/";
      states = {
        low = 0;
        mid = 25;
        high = 50;
      };
    };
    "custom/vpn" = {
      format = "";
      interval = 10;
      return-type = "json";
      exec = "~/.config/waybar/custom/vpn.sh";
    };
    "custom/vm" = {
      format = "";
      interval = 10;
      return-type = "json";
      exec = "~/.config/waybar/custom/kvm-monitor.sh";
      on-click = "~/.config/waybar/custom/kvm.sh";
    };
    "custom/containers" = {
      format = " ";
      interval = 10;
      return-type = "json";
      exec = "~/.config/waybar/custom/containers-monitor.sh";
    };
    "idle_inhibitor" = {
      format = "{icon}";
      format-icons = {
        activated = "﯎";
        deactivated = "﯏";
      };
    };
    "custom/notification" = {
      tooltip = false;
      format = "{} {icon}";
      format-icons = {
        notification = "";
        none = "";
        dnd-notification = "";
        dnd-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client --close-all";
      escape = true;
    };
    "tray" = {
      icon-size = 12;
      spacing = 10;
    };
  };
}
