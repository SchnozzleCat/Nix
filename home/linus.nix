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
  # Combined .NET SDKs. The real runtime tree (host/fxr, shared, packs, ...)
  # lives at "${dotnet}/share/dotnet" (see nixpkgs' combine-packages.nix).
  # DOTNET_ROOT must point there because framework-dependent apphost binaries
  # are exec'd *around* dotnet (e.g. `aspire run` spawns the AppHost directly,
  # so the bin/dotnet wrapper's env never reaches it).
  dotnet = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
      sdk_10_0
    ];
  # Declarative agent skills, linked at ~/.agents/skills. Also passed to
  # makeJailedPi (agentSkills) so the jailed default pi ro-binds the same
  # bundle into its sandbox -- the jail's runtime closure never includes
  # ~/.agents on its own, so without this pi's skill discovery finds
  # nothing inside the sandbox.
  agent-skills = pkgs.symlinkJoin {
    name = "agent-skills";
    paths = [./config/skills] ++ import ./config/remote-agent-skills.nix {inherit pkgs;};
  };
in {
  imports = [
    ./home.nix
    ./terminal.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = {};
    extraConfig = import ./config/hyprland.lua.nix {inherit config pkgs;};
  };

  nixpkgs.config.android_sdk.accept_license = true;

  services.blueman-applet.enable = true;

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
    # theme = {
    #   package = pkgs.layan-gtk-theme;
    #   name = "Layan-Dark";
    # };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 1;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
  ];

  xdg.desktopEntries.oryx = {
    name = "Oryx";
    exec = "${app-browser} --app=https://configure.zsa.io/voyager/layouts/default/latest/0/";
  };

  xdg.desktopEntries.m8webview = {
    name = "M8 Web View";
    exec = "${app-browser} --app=https://derkyjadex.github.io/M8WebDisplay/";
  };

  home.file.".agents/skills" = {
    source = agent-skills;
    recursive = true;
  };

  programs.quickshell = {
    enable = true;
  };

  programs.looking-glass-client.enable = true;

  home.file.".pi/permission.settings.json".text = ''
    {
      "defaultMode": "ask",
      "allow": ["read", "bash(git *)"],
      "deny": ["bash(rm -rf *)"],
      "ask": ["write", "edit"],
      "keybindings": {
        "autoAcceptEdits": "ctrl+shift+a"
      }
    }
  '';

  # pi instance reporter: every running pi process writes its state
  # (working / done / waiting for input) to ~/.cache/pi-instances/<pid>.json,
  # which the Noctalia "linus/pi-instances" plugin (home/linus-desktop.nix)
  # reads for the bar widget light + details panel. Installed into pi's
  # global auto-discovery location, so TUI, RPC and jailed (bwrap binds
  # ~/.pi read-write) pi processes all load it. ~ (bwrap --clearenv) means
  # XDG_CACHE_HOME is unset inside the jail, so both jailed and unjailed
  # instances resolve the same ~/.cache/pi-instances directory. Overrides:
  # PI_INSTANCES_STATE_DIR (see the extension source).
  #
  # `.text` (a real file), NOT `.source` (a symlink): the default `pi` is the
  # bwrap jail (pkgs.makeJailedPi), which bind-mounts only the store paths in
  # its own runtime closure. A home-manager `.source` symlink points into
  # /nix/store/...-home-manager-files, which is NOT in that closure, so inside
  # the jail the symlink dangles and pi's extension discovery silently skips
  # it (statSync fails -> continue). Same reason `.pi/permission.settings.json`
  # above uses `.text`. ~/.pi is bind-mounted read-write, so a real file here
  # is visible (and hot-reloadable via /reload) in jailed and unjailed pi.
  home.file.".pi/agent/extensions/instance-report.ts".text =
    builtins.readFile ./config/pi/agent/extensions/instance-report.ts;

  home = {
    username = "linus";
    homeDirectory = "/home/linus";
    sessionVariables = {
      EDITOR = "nvim";
      TZDIR = "/etc/zoneinfo";
      # Lets framework-dependent apphost binaries (aspire AppHost, dotnet
      # test host, ...) find the runtimes in the combined SDK tree.
      DOTNET_ROOT = "${dotnet}/share/dotnet";
    };
    packages = with pkgs; [
      # Jailed pi coding agent (bwrap sandbox, see lib/jailed-pi.nix).
      # The default `pi` invocation runs the jail's default package set.
      # `extensionPackages` loads the agentic-af extensions
      # (context, fetch, web-search, mcp, rules) via `pi -e` so they're
      # available in every session without editing settings.json. permission
      # is excluded from the TUI build (pi.nvim-only) -- see pkgs/agentic-af.
      (pkgs.makeJailedPi {
        agentSkills = agent-skills;
        extensionPackages = [pkgs.agentic-af];
        # Aspire CLI (inputs.aspire-cli, see flake.nix): self-contained
        # binary auto-patched against icu/openssl/zlib/stdenv.cc.lib --
        # runtime libs the jail's commonPkgs already expose, so pi can
        # `aspire run/publish/etc.` inside the sandbox.
        extraPkgs = [
          inputs.aspire-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        # Expose the custom godot fork's versioned Godot.NET.Sdk/GodotSharp
        # NuGet packages to the jail's dotnet toolchain (offline restore
        # source + fallback folder configured by lib/jailed-pi.nix), so pi
        # can restore/build C# Godot projects inside the jail. Source of
        # truth: modules/home-manager/godot4-mono-schnozzlecat.nix.
        nugetPackages =
          lib.optionals
          config.programs.godot4-mono-schnozzlecat.enable
          config.programs.godot4-mono-schnozzlecat.nugetPackages;
      })

      # OS
      wl-clipboard
      pyprland
      blueman
      hyprshade
      csharprepl

      # Web
      qbittorrent
      yt-dlp
      jetbrains-toolbox
      jellyfin-desktop

      rimsort

      # Dev
      steamcmd
      tracy
      aseprite
      dotnet

      jetbrains.datagrip
      inputs.hyprland-qtutils.packages."${pkgs.stdenv.hostPlatform.system}".default

      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

      # Utilities
      libnotify
      solaar
      wtype
      # Secrets
      sops
      age-plugin-yubikey
      ssh-to-age
      bruno
      thunar
      tidal-hifi
      kubectl
      fswatch
      lmstudio

      # Games
      steam-run
      protonup-qt
      libreoffice
      inetutils

      # Misc
      obsidian
      crosspipe
      easyeffects
      vesktop
      proton-vpn
      nvtopPackages.full
      csharpier

      # Shell Scripts
      (writeShellApplication {
        name = "record-screen";
        text = import ./scripts/record-screen.nix {inherit pkgs;};
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
      (writeShellScriptBin "kk" ''
        nix run ~/Repositories/KomradKat -- "$@"
      '')
      (writeShellApplication {
        name = "twitch-chat-sound";
        runtimeInputs = [python3 pulseaudio libnotify];
        text = ''
          export TWITCH_SOUND="''${TWITCH_SOUND:-${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga}"
          export TWITCH_PLAYER="''${TWITCH_PLAYER:-paplay}"
          exec python3 ${./scripts/twitch-chat-sound.py} "$@"
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
        name = "tc-lan-latency";
        text = ''
          delay="''${1:-100ms}"
          host="''${2:-192.168.200.9}"
          dev="$(ip route get "$host" | awk '{for (i = 1; i <= NF; i++) if ($i == "dev") {print $(i+1); exit}}')"
          if [ -z "$dev" ]; then
            echo "no route to $host" >&2
            exit 1
          fi
          echo "delaying $delay to/from $host via $dev"
          sudo tc qdisc add dev "$dev" root handle 1: prio
          sudo tc qdisc add dev "$dev" parent 1:1 handle 10: netem delay "$delay"
          sudo tc filter add dev "$dev" protocol ip parent 1:0 prio 1 u32 match ip dst "$host"/32 flowid 1:1
          sudo tc filter add dev "$dev" protocol ip parent 1:0 prio 1 u32 match ip src "$host"/32 flowid 1:1
        '';
      })
      (writeShellApplication {
        name = "tc-lan-reset";
        text = ''
          host="''${1:-192.168.200.9}"
          dev="$(ip route get "$host" | awk '{for (i = 1; i <= NF; i++) if ($i == "dev") {print $(i+1); exit}}')"
          sudo tc qdisc del dev "$dev" root
        '';
      })
      (writeShellApplication {
        name = "tc-reset";
        text = ''
          sudo tc qdisc del dev lo root
        '';
      })
      (writeShellApplication {
        name = "where";
        text = ''
          readlink -e "$(which "$1")"
        '';
      })
      (writeShellApplication {
        name = "virtual-audio";
        runtimeInputs = [pulseaudio];
        text = ''
          name="''${1:-Virtual}"
          pactl load-module module-null-sink \
            sink_name="$name" \
            sink_properties=device.description="$name"
        '';
      })
      (writeShellApplication {
        name = "stream-start";
        runtimeInputs = [pulseaudio];
        text = ''
          pids=()

          cleanup() {
            echo "[stream-start] shutting down..."
            for pid in "''${pids[@]}"; do
              kill "$pid" 2>/dev/null || true
            done
            if [[ -n "''${music_module:-}" ]]; then
              pactl unload-module "$music_module" 2>/dev/null || true
            fi
          }
          trap cleanup EXIT INT TERM

          echo "[stream-start] creating 'music' virtual audio cable"
          music_module=$(virtual-audio music)

          echo "[stream-start] listening to #schnozzlecat chat"
          twitch-chat-sound schnozzlecat &
          pids+=("$!")

          echo "[stream-start] running (Ctrl-C to stop)"
          wait
        '';
      })
    ];
  };

  programs.godot4-mono-schnozzlecat = {
    enable = true;
    version = "4.7";
    rev = "7da4fae2b0456e15ec8b606396735c9a000f5d16";
    hash = "sha256-gE6s+TLi4i0THXpL5xXNdqvjA2PlYQPtsUPnj+L0u8o=";
    withTracy = true;
    withTracyTrackMemory = true;
    withTracyExportCapi = true;
  };

  programs.imv = {
    enable = true;
    settings.options.background = "ffffff";
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
      "text/html" = ["zen.desktop"];
      "x-scheme-handler/http" = ["zen.desktop"];
      "x-scheme-handler/https" = ["zen.desktop"];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "SchnozzleCat";
        email = "linus@schnozzlecat.xyz";
      };
    };
    signing = {
      key = "537B FDDE 066D 4D00 E6B1  5D90 21FB 9DA7 99F8 7226";
      signByDefault = true;
    };
  };

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

  home.file.".config/hypr/hyprpaper.conf".text = import ./config/hyprpaper.nix;

  home.file.".config/pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads", "expose", "magnify"]

    [scratchpads.term]
    command = "alacritty --class terminal-float -e zellij"
    animation = "fromBottom"
    margin = 50
  '';

  home.file.".config/hypr/hyprshade.toml".text = ''
    [[shades]]
    name = "blue-light-filter-custom"
    start_time = 19:00:00
    end_time = 06:00:00
  '';

  home.file.".config/hypr/hyprlock.conf".text = import ./config/hyprlock.nix;

  home.file.".config/hypr/shaders/blue-light-filter-custom.glsl".text = ''
    /*
     * Blue Light Filter
     *
     * Use warmer colors to make the display easier on your eyes.
     *
     * Source: https://github.com/hyprwm/Hyprland/issues/1140#issuecomment-1335128437
     */

    #version 300 es
    precision highp float;

    in vec2 v_texcoord;
    uniform sampler2D tex;
    out vec4 fragColor;

    /**
     * Color temperature in Kelvin.
     * https://en.wikipedia.org/wiki/Color_temperature
     *
     * @min 1000.0
     * @max 40000.0
     */
    const float Temperature = float(4300.0);

    /**
     * Strength of filter.
     *
     * @min 0.0
     * @max 1.0
     */
    const float Strength = float(1.0);

    #define WithQuickAndDirtyLuminancePreservation
    const float LuminancePreservationFactor = 1.0;

    // function from https://www.shadertoy.com/view/4sc3D7
    // valid from 1000 to 40000 K (and additionally 0 for pure full white)
    vec3 colorTemperatureToRGB(const in float temperature) {
        // values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693
        mat3 m = (temperature <= 6500.0)
            ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                   vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                   vec3(1.0, 1.3302673723350029, 1.8993753891711275))
            : mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                   vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                   vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));

        return mix(
            clamp(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2], 0.0, 1.0),
            vec3(1.0),
            smoothstep(1000.0, 0.0, temperature)
        );
    }

    void main() {
        vec4 pixColor = texture(tex, v_texcoord);
        vec3 color = pixColor.rgb;

    #ifdef WithQuickAndDirtyLuminancePreservation
        float lum = dot(color, vec3(0.2126, 0.7152, 0.0722));
        color *= mix(1.0, lum / max(lum, 1e-5), LuminancePreservationFactor);
    #endif

        color = mix(color, color * colorTemperatureToRGB(Temperature), Strength);

        fragColor = vec4(color, pixColor.a);
    }

    // vim: ft=glsl
  '';

  programs.waybar = {
    enable = true;
    settings = import ./config/waybar-config.nix {inherit pkgs;};
    style = import ./config/waybar-style.nix;
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

  programs.alacritty = {
    enable = true;
    settings = {
      general.import = ["~/.config/alacritty/themes/noctalia.toml"];
      font.size = 10;
      window.opacity = 0.9;
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
        terminal = "alacritty -e";
        prompt = "       ";
        layer = "overlay";
      };
      colors = {
        background = "161a1eff";
        text = "E7EAEEff";
        match = "89BEFFff";
        selection = "3f4552ff";
        selection-match = "89BEFFff";
        selection-text = "E7EAEEff";
        border = "739fd4ff";
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
