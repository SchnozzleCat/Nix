''
  @define-color text     #ecc78e;

  * {
    border: none;
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 15px;
    background: none;
  }

  #waybar {
    border-radius: 0px;
    background: none;
  }

  #workspaces button {
    padding: 0 0 0 0;
    margin: 6px 4px 4px 4px;
    background-color: transparent;
    border-radius: 0px;
    border-top: 2px solid transparent;
    border-bottom: 2px solid transparent;
    color: @text;
    min-width: 36px;
    background: rgba(0, 0, 0, 0.3);
  }

  #workspaces button.active {
    padding: 0 0 0 0;
    margin: 6px 4px 4px 4px;
    border-top: 2px solid #b84b4d;
    border-bottom: 2px solid #b84b4d;
    border-radius: 0px;
    min-width: 36px;
    background: rgba(0, 0, 0, 0.7);
  }

  #workspaces button:hover {
    background: rgba(0, 0, 0, 0.3);
  }

  #workspaces button.focused {
    background-color: @mauve;
    color: @base;
  }

  #workspaces button.urgent {
    padding: 0 0 0 0;
    margin: 6px 4px 4px 4px;
    border-top: 2px solid #e64553;
    border-bottom: 2px solid #e64553;
    border-radius: 0px;
    min-width: 36px;
    background: rgba(0, 0, 0, 0.7);
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

  #network,
  #pulseaudio,
  #battery,
  #battery,
  #backlight,
  #clock,
  #memory,
  #cpu,
  #custom-vpn,
  #disk,
  #custom-containers,
  #custom-vm,
  #temperature,
  #tray,
  #custom-gpu-temperature {
    transition: none;
    color: @text;
    margin: 6px 16px 4px 16px;
    padding: 1px 15px 1px 15px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 10px;
  }

  #custom-vm {
    padding: 1px 17px 1px 15px;
  }

  #tray menu {
    background: rgba(0.3, 0.3, 0.3, 0.7);
    border-radius: 15px;
  }

  .active {
    padding: 14px;
    margin: 14px;
  }

  #battery.critical:not(.charging) {
    background-color: #9f9c9d;
    color: @text;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
    margin: 6px 4px 4px 4px;
  }
''
