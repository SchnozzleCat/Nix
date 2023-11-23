{
  mainBar = {
    id = "top";
    height = 0;
    margin = "0px 5px 0p 0px";
    name = "top";
    layer = "top";
    position = "top";
    modules-right = ["custom/notification" "sway/mode" "custom/spotify" "clock" "tray" "pulseaudio" "backlight" "battery"];
    modules-center = ["hyprland/workspaces"];
    "modules-left" = ["disk" "memory" "cpu" "temperature" "custom/gpu-temperature" "custom/containers" "custom/vm" "custom/vpn"];
    "hyprland/workspaces" = {
    };

    "clock" = {
      format = "{:%a %d %b %H:%M}";
      tooltip = true;
      on-click = "swaync-client -t -sw";
    };
    "clock#utc" = {
      format = "{=%H=%M UTC}";
      timezone = "Etc/UTC";
      on-click = "swaync-client -t -sw";
    };
    "sway/mode" = {
      format = "";
    };
    "temperature" = {
      thermal-zone = 2;
      format = "󱃃 {temperatureC}°C";
    };

    "custom/gpu-temperature" = {
      format = "{}";
      interval = 10;
      exec = "sensors amdgpu-pci-0300 | grep junction | awk '{print $2}'";
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
    "custom/spotify" = {
      format = "{}";
      escape = true;
      return-type = "json";
      max-length = 100;
      interval = 10;
      on-click = "playerctl -p spotify play-pause";
      on-click-right = "killall spotify";
      smooth-scrolling-threshold = 5;
      on-scroll-up = "playerctl -p spotify next";
      on-scroll-down = "playerctl -p spotify previous";
      exec = "$HOME/.config/waybar/custom/spotify.sh";
      exec-if = "pgrep spotify";
    };
    "network" = {
      format = "{icon}";
      format-icons = {
        wifi = ["﬉"];
        ethernet = [""];
        disconnected = [""];
      };
      format-alt-click = "click-right";
      format-wifi = "﬉";
      format-ethernet = "";
      format-disconnected = "睊";
      tooltip-format = "{ifname} via {gwaddr}";
      tooltip-format-wifi = "    {essid} ﬉\n{ipaddr} {signalStrength}%";
      tooltip-format-ethernet = "{ifname} {ipaddr} ";
      tooltip-format-disconnected = "Disconnected";
      on-click = "gnome-control-center network";
      tooltip = true;
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
      format = " {usage}%";
      format-alt-click = "click-right";
      states = {
        low = 0;
        mid = 25;
        high = 50;
      };
    };
    "memory" = {
      interval = 30;
      format = " {used:0.1f}G/{total:0.1f}G";
      tooltip-format = "{used:0.1f}G used\n{avail:0.1f}G available\n{total:0.1f}G total";
      format-alt-click = "click-right";
      states = {
        low = 0;
        mid = 50;
        high = 75;
      };
    };
    "disk" = {
      interval = 30;
      format = "󰨣 {used}/{free}";
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
    "custom/bluelightfilter" = {
      format = "";
      interval = 10;
      return-type = "json";
      on-click = "~/.config/waybar/custom/bluelightfilter-toggle.sh";
      signal = 8;
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
    "custom/spotify-metadata" = {
      format = "{}  ";
      max-length = 60;
      interval = 30;
      return-type = "json";
      exec = "~/.config/waybar/custom/spotify/metadata.sh";
      on-click = "~/.config/waybar/custom/spotify/controls.sh";
      on-scroll-up = "~/.config/waybar/custom/spotify/controls.sh next";
      on-scroll-down = "~/.config/waybar/custom/spotify/controls.sh previous";
      signal = 5;
      smooth-scrolling-threshold = 1.0;
    };
    "wlr/taskbar" = {
      format = "{icon}";
      sort-by-app-id = true;
      icon-size = 13;
      icon-theme = "Numix-Circle";
      tooltip-format = "{title}";
      on-click = "activate";
      on-click-right = "close";
      markup = true;
      ignore-list = [
        "kitty"
      ];
    };
    "sway/scratchpad" = {
      format = "{icon}";
      show-empty = false;
      format-icons = ["" ""];
      tooltip = true;
      tooltip-format = "{app}= {title}";
    };
  };
}
