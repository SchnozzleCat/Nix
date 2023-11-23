{config}: let
  colors = config.colorScheme.colors;
in ''
  * {
    border: none;
    border-radius: 10px;
    font-family: "SauceCodePro Nerd Font";
    font-size: 15px;
    min-height: 10px;
  }

  window#waybar {
    background: transparent;
  }

  window#waybar.hidden {
    opacity: 0.2;
  }

  #window {
    margin-top: 6px;
    padding-left: 10px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: transparent;
    background: transparent;
  }
  #tags {
    margin-top: 6px;
    margin-left: 12px;
    font-size: 4px;
    margin-bottom: 0px;
    border-radius: 10px;
    min-width: 0;
    background: #0e1218;
    transition: none;
  }

  #tags button {
    min-width: 50px;
    transition: none;
    color: #dfd2c4;
    background: transparent;
    font-size: 16px;
    border-radius: 2px;
  }

  #tags button.occupied {
    transition: none;
    color: #c5663d;
    background: transparent;
    font-size: 4px;
  }

  #tags button.focused {
    color: #cc8a5e;
    border-top: 2px solid #cc8a5e;
    border-bottom: 2px solid #cc8a5e;
  }

  #tags button:hover {
    transition: none;
    box-shadow: inherit;
    text-shadow: inherit;
    color: #${colors.base05};
    border-color: #${colors.base05};
    color: #${colors.base05};
  }

  #tags button.focused:hover {
    color: #${colors.base05};
  }

  #tags button.urgent {
    border-top: 2px solid #fb4934;
    border-bottom: 2px solid #fb4934;
  }

  #workspaces button {
    padding: 0 0 0 0;
    margin: 4px 3px 2px 3px;
    background-color: @surface0;
    color: #${colors.base05};
    min-width: 36px;
  }

  #workspaces button.active {
    padding: 0 0 0 0;
    margin: 4px 3px 2px 3px;
    background-color: #8e9ebe;
    color: #0e1218;
    min-width: 36px;
  }

  #workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
  }

  #workspaces button.focused {
    background-color: @mauve;
    color: #${colors.base00};
  }

  #workspaces button.urgent {
    background-color: #e64553;
  }

  #window,
  #workspaces {
    margin: 0 4px;
  }

  .modules-left > widget:first-child > #workspaces {
    margin-left: 0;
  }

  .modules-right > widget:first-child > #workspaces {
    margin-right: 0;
  }

  #network {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #c5663d;
  }

  #pulseaudio {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0A};
  }

  #battery {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #9f9c9d;
  }

  #battery.charging,
  #battery.plugged {
    color: #${colors.base05};
    background-color: #9f9c9d;
  }

  #battery.critical:not(.charging) {
    background-color: #9f9c9d;
    color: #${colors.base05};
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
  }

  @keyframes blink {
    to {
      background-color: #bf616a;
      color: #9f9c9d;
    }
  }

  #backlight {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #d3a46e;
  }
  #clock {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base07};
    /*background: #1A1826;*/
  }

  #custom-notification {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base07};
    /*background: #1A1826;*/
  }

  #memory {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0A};
  }
  #scratchpad {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0A};
  }
  #cpu {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0F};
  }

  #custom-spotify {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0F};
  }

  #custom-vpn {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0F};
  }
  #idle_inhibitor {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0C};
  }

  #disk {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0C};
  }

  #custom-containers {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0C};
  }
  #custom-vm {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0C};
  }
  #temperature {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: #${colors.base0D};
  }
  #custom-gpu-temperature {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: @lavender;
  }

  #custom-bluelightfilter {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: @green;
  }
  #tray {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    margin-bottom: 0px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base00};
    background: @overlay0;
  }

  #custom-launcher {
    font-size: 24px;
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 5px;
    border-radius: 10px;
    transition: none;
    color: #cc8a5e;
    background: #202937;
  }

  #custom-power {
    font-size: 20px;
    margin-top: 6px;
    margin-left: 8px;
    margin-right: 8px;
    padding-left: 10px;
    /* padding-right: 5px; */
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #cc8a5e;
    background: #202937;
  }

  #custom-wallpaper {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #c9cbff;
  }

  #custom-updates {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #e8a2af;
  }

  #custom-media {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #7a7e86;
  }
  #custom-mpc {
    margin-top: 6px;
    margin-left: 8px;
    padding-left: 10px;
    padding-right: 10px;
    margin-bottom: 0px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #926d54;
  }
''
