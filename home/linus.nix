{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nix-colors,
  master,
  ...
}: let
  colors = config.colorScheme.palette;
  app-browser = "${pkgs.brave}/bin/brave";
in {
  imports = [
    ./home.nix
    ./terminal.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # plugins = with inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}; [
    #   inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
    # ];
  };
  nixpkgs.config.android_sdk.accept_license = true;

  programs.command-not-found.enable = true;

  gtk = {
    enable = true;
    gtk2.extraConfig = ''
      gtk-error-bell = 0
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
    '';
    gtk3.extraConfig = {
      gtk-error-bell = 0;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    gtk4.extraConfig = {
      gtk-error-bell = 0;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    theme = {
      package = pkgs.layan-gtk-theme;
      name = "Layan-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 1;
    };
    # iconTheme = {
    #   package = pkgs.tela-circle-icon-theme;
    #   name = "Tela-circle-dark";
    # };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  xdg.desktopEntries.oryx = {
    name = "Oryx";
    exec = "${app-browser} --app=https://configure.zsa.io/voyager/layouts/default/latest/0/";
  };

  xdg.desktopEntries.m8webview = {
    name = "M8 Web View";
    exec = "${app-browser} --app=https://derkyjadex.github.io/M8WebDisplay/";
  };

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      # OS
      wl-clipboard
      pyprland
      wally-cli
      blueman
      hyprshade
      moonlight-embedded
      csharprepl
      goose-cli

      # Web
      qbittorrent
      yt-dlp
      k6
      jetbrains-toolbox

      # Dev
      # unityhub
      zed-editor
      devbox
      (
        with dotnetCorePackages;
          combinePackages [
            sdk_8_0
            sdk_9_0
          ]
      )
      sublime-merge
      (pkgs.buildDotnetGlobalTool {
        pname = "Microsoft.dotnet-interactive";
        version = "1.0.522904";
        nugetHash = "sha256-ULnG2D7BUJV39cSC4sarWlrngtv492vpd/BjeB5dKYQ=";
        executables = "dotnet-interactive";
        dotnet-runtime = pkgs.dotnetCorePackages.sdk_9_0;
        dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
      })

      # jetbrains.rider
      # jetbrains.datagrip
      inputs.hyprland-qtutils.packages."${pkgs.system}".default

      gdtoolkit_4
      inky

      bitwarden

      inputs.zen-browser.packages."${pkgs.system}".default

      # Utilities
      lm_sensors
      solaar
      wtype
      git-crypt
      bruno
      xfce.thunar
      minikube
      kubectl
      kubernetes

      # Games
      steam-run
      steam-tui
      steamcmd
      protonup-qt
      protontricks
      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
          gamescope
          mesa
        ];
      })
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      winetricks
      bottles
      runelite
      libreoffice
      scribus

      # Misc
      obsidian
      helvum
      easyeffects
      warpinator
      vesktop
      jellyfin-media-player
      mpv
      mpv-shim-default-shaders
      latexrun
      distrobox
      # wonderdraft
      krita
      aseprite
      protonvpn-gui
      gh-copilot
      rocmPackages.rocm-smi
      nvtopPackages.full
      vdhcoapp
      # smassh
      (buildDotnetGlobalTool {
        pname = "csharpier";
        version = "1.0.0";
        executables = "csharpier";

        nugetHash = "sha256-wj+Sjvtr4/zqBdxXMM/rYHykzcn+jQ3AVakYpAa3sNU=";

        meta = with lib; {
          description = "Opinionated code formatter for C#";
          homepage = "https://csharpier.com/";
          changelog = "https://github.com/belav/csharpier/blob/main/CHANGELOG.md";
          license = licenses.mit;
          maintainers = with maintainers; [zoriya];
          mainProgram = "csharpier";
        };
      })

      # Shell Scripts
      (writeShellApplication {
        name = "power-menu";
        text = import ./scripts/power-menu.nix;
      })
      (writeShellApplication {
        name = "record-screen";
        text = import ./scripts/record-screen.nix {inherit pkgs;};
      })
      (writeShellApplication {
        name = "translate-en-to-de";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="EN -> DE: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.translate-shell}/bin/trans -no-ansi en:de "$text" | fuzzel --dmenu --width=50 --lines=20
        '';
      })
      (writeShellApplication {
        name = "convert-cards";
        text = ''
          ${pkgs.poppler-utils}/bin/pdftoppm -png "$1" "$1"-images
          ${pkgs.imagemagick}/bin/convert "$1"-images-* -shave 10x10 "$1"-cropped.png
        '';
      })
      (writeShellApplication {
        name = "translate-de-to-en";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="DE -> EN: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.translate-shell}/bin/trans -no-ansi de:en "$text" | fuzzel --dmenu --width=50 --lines=20
        '';
      })
      (writeShellApplication {
        name = "synonym";
        text = ''
          text=$(echo "" | fuzzel --dmenu --dmenu --prompt="Synonym: " --lines=0)
          if [ -z "$text" ]; then exit; fi
          ${pkgs.wordnet}/bin/wn "$text" -synsn -synsv -synsa -synsr | fuzzel --dmenu --width=50 --lines=20
        '';
      })
      (writeShellApplication {
        name = "pipe-notify";
        text = ''
          NID=''$(${pkgs.libnotify}/bin/notify-send -p "...")
          MESSAGE=""
          while IFS= read -r -n 1 char || [[ -n "$char" ]]; do
            if [[ -z "$char" ]]; then
              MESSAGE="$MESSAGE\n"
            else
              MESSAGE="$MESSAGE$char"
            fi
            ${pkgs.libnotify}/bin/notify-send -r "$NID" "Shell" "$MESSAGE"
          done
        '';
      })
      (writeShellApplication {
        name = "vpn-status";
        text = ''
          vpn=$(ifconfig | grep tun)

          if [[ $vpn ]]
          then
             echo "{\"class\": \"running\", \"text\": \"\", \"tooltip\": \"\"}"
             exit
          fi
        '';
      })
      (writeShellApplication {
        name = "soundscaper";
        text = ''
          echo "$1" | ${pkgs.socat}/bin/socat - UNIX-CONNECT:/tmp/CoreFxPipe_SoundScaper
        '';
      })
      (writeShellApplication {
        name = "dvt";
        text = ''
          nix flake init -t "github:SchnozzleCat/dev-templates#$1"
          direnv allow
        '';
      })
      (writeShellApplication {
        name = "tc-latency";
        text = ''
          sudo tc qdisc add dev lo root handle 1: prio
          sudo tc qdisc add dev lo parent 1:1 handle 10: netem delay "$1"
          sudo tc filter add dev lo protocol ip parent 1:0 prio 1 u32 match ip dst 192.168.200.20/32 flowid 1:1
          sudo tc filter add dev lo protocol ip parent 1:0 prio 1 u32 match ip src 192.168.200.20/32 flowid 1:1
        '';
      })
      (writeShellApplication {
        name = "tc-reset";
        text = ''
          sudo tc qdisc del dev lo root
        '';
      })
      (writeShellApplication {
        name = "ghs";
        text = ''
          gh copilot suggest "$*"
        '';
      })
      (writeShellApplication {
        name = "ghe";
        text = ''
          gh copilot explain "$*"
        '';
      })
      (writeShellApplication {
        name = "where";
        text = ''
          readlink -e "$(which "$1")"
        '';
      })
      (writeShellScriptBin "autobuild-godot" ''
        FOCUSED=$(hyprctl activewindow | grep Godot)

        while true
        do
          NEW_FOCUS=$(hyprctl activewindow | grep Godot)
          if [[ -n "$NEW_FOCUS" && -z "$FOCUSED" ]]; then
            dotnet build
          fi
          FOCUSED=$NEW_FOCUS
          sleep .5
        done
      '')
    ];
  };

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
    ];
    theme = spicePkgs.themes.text;
  };

  programs.godot4-mono-schnozzlecat = {
    enable = true;
    version = "4.4.1";
    commitHash = "4093498c254cf24aad3afddf1b4b29423744e6ff";
    hash = "sha256-DyWVGLmK5JbhKYUdHIBHyDMZEjZ/N7Ooyfpir2+kAEk=";
  };

  programs.ncspot = {
    enable = true;
    settings = {
      keybindings = {
        "Ctrl+f" = "focus search";
        "Ctrl+q" = "focus queue";
        "Ctrl+l" = "focus library";
      };
    };
  };

  # services.pulseeffects = {
  #   enable = true;
  # };

  programs.imv = {
    enable = true;
  };

  programs.mpv = {
    enable = true;
    config = {
      audio-device = "pulse";
    };
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "inode/directory" = ["yazi.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "image/*" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "image/jpg" = ["imv.desktop"];
      "image/svg+xml" = ["imv.desktop"];
    };
    defaultApplications = {
      "inode/directory" = ["yazi.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "image/*" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "image/jpg" = ["imv.desktop"];
      "image/svg+xml" = ["imv.desktop"];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "SchnozzleCat";
    userEmail = "linus@schnozzlecat.xyz";
    signing = {
      key = "537B FDDE 066D 4D00 E6B1  5D90 21FB 9DA7 99F8 7226";
      signByDefault = true;
    };
  };

  home.file.".ideavimrc".source = ./.ideavimrc;

  programs.mangohud = {
    enable = true;
    settings = {
      vulkan_driver = true;
      gpu_temp = true;
      gpu_mem_temp = true;
      vram = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_mhz = true;
      ram = true;
      io_read = true;
      io_write = true;
      gamemode = true;
    };
  };

  services.network-manager-applet.enable = true;

  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = ["scratchpads", "expose", "magnify"]

    [scratchpads.term]
    command = "foot -a foot-float -- zellij"
    animation = "fromBottom"
    margin = 50

    [scratchpads.ncspot]
    command = "sleep 3 && foot -a foot-ncspot ncspot"
    animation = "fromBottom"
    margin = 50
  '';

  home.file.".config/hypr/hyprshade.toml".text = ''
    [[shades]]
    name = "blue-light-filter-custom"
    start_time = 19:00:00
    end_time = 06:00:00
  '';

  home.file.".config/hypr/hyprlock.conf".text = import ./hyprlock.nix;

  home.file.".config/hypr/shaders/blue-light-filter-custom.glsl".text = ''
    #version 300 es
    // from https://github.com/hyprwm/Hyprland/issues/1140#issuecomment-1335128437

    precision highp float;
    varying vec2 v_texcoord;
    uniform sampler2D tex;

    const float temperature = 4300.0;
    const float temperatureStrength = 1.0;

    #define WithQuickAndDirtyLuminancePreservation
    const float LuminancePreservationFactor = 1.0;

    // function from https://www.shadertoy.com/view/4sc3D7
    // valid from 1000 to 40000 K (and additionally 0 for pure full white)
    vec3 colorTemperatureToRGB(const in float temperature) {
        // values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693
        mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                                vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                                vec3(1.0, 1.3302673723350029, 1.8993753891711275))
                                         : mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                                vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                                vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
        return mix(clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
                   vec3(1.0), smoothstep(1000.0, 0.0, temperature));
    }

    void main() {
        vec4 pixColor = texture2D(tex, v_texcoord);

        // RGB
        vec3 color = vec3(pixColor[0], pixColor[1], pixColor[2]);

    #ifdef WithQuickAndDirtyLuminancePreservation
        color *= mix(1.0, dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                     LuminancePreservationFactor);
    #endif

        color = mix(color, color * colorTemperatureToRGB(temperature), temperatureStrength);

        vec4 outCol = vec4(color, pixColor[3]);

        gl_FragColor = outCol;
    }
  '';

  programs.waybar = {
    enable = true;
    settings = import ./waybar-config.nix {inherit pkgs;};
    style = import ./waybar-style.nix;
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        source = ./pub.asc;
      }
    ];
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=10";
        gamma-correct-blending = "no";
      };
      cursor = {
        color = "1A1826 D9E0EE";
      };
      colors = {
        alpha = 0.8;
        foreground = colors.base05;
        background = colors.base00;
        regular0 = colors.base02;
        regular1 = colors.base08;
        regular2 = colors.base0B;
        regular3 = colors.base09;
        regular4 = colors.base0D;
        regular5 = colors.base0E;
        regular6 = colors.base0C;
        regular7 = colors.base06;
        bright0 = colors.base02;
        bright1 = colors.base08;
        bright2 = colors.base0B;
        bright3 = colors.base09;
        bright4 = colors.base0D;
        bright5 = colors.base0E;
        bright6 = colors.base0C;
        bright7 = colors.base06;
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        width = 35;
        font = "JetBrainsMono Nerd Font:size=16";
        icon-theme = "Tela-circle-dark";
        line-height = 25;
        fields = "name,generic,comment,categories,filename,keywords";
        terminal = "foot -e";
        prompt = "       ";
        layer = "overlay";
      };
      colors = {
        background = "${colors.base00}aa";
        selection = "${colors.base01}aa";
        border = "${colors.base08}ff";
      };
      border = {
        radius = 5;
        width = 2;
      };
      dmenu = {
        exit-immediately-if-empty = "yes";
      };
    };
  };

  services.fnott = {
    enable = true;
    settings = {
      main = {
        background = "${colors.base00}ff";
        icon-theme = "Tela-circle-dark";
        selection-helper = "fuzzel --dmenu";
        border-size = 1;
        border-color = "${colors.base08}ff";
        title-color = "${colors.base0A}ff";
        body-color = "${colors.base05}ff";
        body-font = "JetBrainsMono Nerd Font";
        title-font = "JetBrainsMono Nerd Font";
        min-width = 600;
        max-width = 600;
        output = "DP-1";
      };
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      recolor = 1;
      recolor-lightcolor = "#1E1D2D";
      recolor-darkcolor = "#838796";
      default-bg = "#838796";
      selection-clipboard = "clipboard";
    };
    mappings = {
      "<C-z>" = "recolor";
    };
  };
}
