{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.pi-sandbox;
  pi-sandbox = import ../../pkgs/pi-sandbox-image.nix {
    inherit pkgs lib;
    hostCommands = cfg.hostCommands;
  };
  piImage = pi-sandbox.image;

  nsenterWrapper = import ../../pkgs/pi-sandbox-nsenter.nix {inherit pkgs;};

  # pasta network spec for --no-firewall mode when testcontainers support is on:
  # a deterministic address+gateway with --map-gw so the gateway resolves to
  # the host's loopback, where the host rootless podman daemon publishes ports.
  tcNetwork = if cfg.forwardTestcontainers && cfg.forwardDocker
    then "pasta:--address,10.200.200.1,--gateway,10.200.200.2,--map-gw"
    else "pasta";
in {
  options = {
    programs.pi-sandbox = {
      enable = mkEnableOption (mdDoc "Pi coding agent sandboxed in Podman");

      forwardGpg = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Forward the GPG agent and password store into the container, enabling `pass` inside the sandbox.";
      };

      forwardGitConfig = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Forward ~/.config/git/config into the container.";
      };

      forwardClaude = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Forward the host Claude Code config (~/.claude and ~/.claude.json)
          into the container so `claude` runs authenticated, via
          CLAUDE_CONFIG_DIR=/claude-config. Mounted read-write: the sandboxed
          agent can read your OAuth token and modify your host Claude state
          (project history, settings), so the sandbox's isolation no longer
          fully covers Claude credentials.
        '';
      };

      extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = mdDoc "Extra env vars passed to every sandbox container via -e.";
      };

      extraMounts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = mdDoc "Extra podman mount flags (e.g. [ \"-v /some/path:/some/path:ro\" ]).";
      };

      networkAccess = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable network access. When false, the container runs with --network none.";
      };

      forwardDocker = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Forward the host rootless Podman socket into the container so
          `docker` (and `podman`) commands run against the host daemon.
          The socket is your user Podman socket at
          $XDG_RUNTIME_DIR/podman/podman.sock, which is started
          automatically as a systemd user socket. Inside the container it
          is mounted at /run/podman/podman.sock and exposed via
          DOCKER_HOST/CONTAINER_HOST.
        '';
      };

      forwardTestcontainers = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Make docker/podman-driven test containers reachable from the sandbox
          when run without the firewall (`sandbox --no-firewall`). In no-firewall
          mode the host rootless Podman daemon publishes test-container ports on
          the host's loopback; this adds a pasta `--map-gw` route to a pinned
          gateway address (10.200.200.2) that maps to host-loopback, and exports
          the standard TESTCONTAINERS_* env vars so testcontainers libraries
          resolve published ports back to that gateway.

          Requires forwardDocker. Only effective in --no-firewall mode: with the
          firewall on, test containers run in the host netns and are unreachable
          without a dedicated in-netns podman daemon.

          Side effects: TESTCONTAINERS_RYUK_DISABLED and
          TESTCONTAINERS_CHECKS_DISABLED are set (Ryuk does not start cleanly
          under a forwarded rootless podman socket), so testcontainers relies on
          its own cleanup instead of the Ryuk reaper container.
        '';
      };

      hostCommands = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            command = mkOption {
              type = types.str;
              description = mdDoc "Absolute path to the host binary.";
            };
            allowedArgs = mkOption {
              type = types.listOf (types.listOf types.str);
              default = [];
              description = mdDoc ''
                Allowed argument prefixes. Each entry is a list of strings.
                The request args must start with one of these prefixes.
                Extra args after the prefix are passed through.
              '';
            };
          };
        });
        default = {};
        description = mdDoc ''
          Commands the container may execute on the host. Each key becomes a
          wrapper binary inside the container that transparently forwards to the
          host via a Unix socket.
        '';
      };
    };
  };

  config = mkIf cfg.enable (
    let
      sandbox = pkgs.writeShellApplication {
        name = "sandbox";
        runtimeInputs = [pkgs.podman pkgs.pass pkgs.coreutils pkgs.gnupg pkgs.socat];
        text = ''
          IMAGE="pi-sandbox:latest"
          IMAGE_PATH="${piImage}"

          # Parse flags
          PORTS=()
          HOST_PORTS=()
          NO_FIREWALL=false
          while [ $# -gt 0 ]; do
            case "$1" in
              -p)
                PORTS+=("-p" "$2")
                HOST_PORTS+=("$2")
                shift 2
                ;;
              --no-firewall)
                NO_FIREWALL=true
                shift
                ;;
              *) break ;;
            esac
          done

          # Ensure the image is loaded into podman
          if ! podman image exists "$IMAGE" 2>/dev/null; then
            echo "Loading sandbox container image..." >&2
            if ! podman load < "$IMAGE_PATH" >/dev/null; then
              echo "sandbox: failed to load container image, aborting" >&2
              exit 1
            fi
          fi

          # Forward ~/.gitconfig if enabled
          declare -a GIT_FLAGS=()
          ${optionalString cfg.forwardGitConfig ''
            if [ -f "$HOME/.config/git/config" ]; then
              GIT_FLAGS+=("-v" "$HOME/.config/git/config:/etc/gitconfig:ro")
            fi
          ''}

          # Forward GPG agent and password store
          declare -a GPG_FLAGS=()
          ${optionalString cfg.forwardGpg ''
            ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent 2>/dev/null || true
            GPG_SOCKET="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket)"
            KEYBOXD_SOCKET="$(${pkgs.gnupg}/bin/gpgconf --list-dirs keyboxd-socket)"

            if [ -S "$GPG_SOCKET" ] && [ -d "$HOME/.gnupg" ] && [ -d "$HOME/.password-store" ]; then
              GPG_FLAGS+=(
                "-v" "$HOME/.gnupg:/home/sandbox/.gnupg:ro"
                "-v" "$GPG_SOCKET:/home/sandbox/.gnupg/S.gpg-agent"
                "-v" "$HOME/.password-store:/home/sandbox/.password-store:ro"
              )
              if [ -S "$KEYBOXD_SOCKET" ]; then
                GPG_FLAGS+=("-v" "$KEYBOXD_SOCKET:/home/sandbox/.gnupg/S.keyboxd")
              fi
              GPG_FLAGS+=("-e" "GNUPGHOME=/home/sandbox/.gnupg" "-e" "PASSWORD_STORE_DIR=/home/sandbox/.password-store")
            else
              echo "sandbox: GPG agent socket not found or missing ~/.gnupg / ~/.password-store, skipping GPG forwarding" >&2
            fi
          ''}

          # Forward host Claude Code config so `claude` runs authenticated.
          # Claude stores its config dir at CLAUDE_CONFIG_DIR but keeps
          # .claude.json beside it, so both are mounted: the dir carries the
          # OAuth token (.credentials.json) + settings/sessions, and the file
          # carries onboarding/trust state so no re-onboarding is needed.
          declare -a CLAUDE_FLAGS=()
          ${optionalString cfg.forwardClaude ''
            if [ -d "$HOME/.claude" ]; then
              CLAUDE_FLAGS+=(
                "-v" "$HOME/.claude:/claude-config"
                "-e" "CLAUDE_CONFIG_DIR=/claude-config"
              )
              if [ -f "$HOME/.claude.json" ]; then
                CLAUDE_FLAGS+=("-v" "$HOME/.claude.json:/claude-config/.claude.json")
              fi
            else
              echo "sandbox: ~/.claude not found, skipping Claude config forwarding" >&2
            fi
          ''}

          # Forward the host rootless Podman socket so `docker`/`podman` inside
          # the sandbox talk to the host daemon. The socket is owned by the
          # calling user, so it maps cleanly under --userns=keep-id.
          declare -a DOCKER_FLAGS=()
          ${optionalString cfg.forwardDocker ''
            DOCKER_SOCK="$XDG_RUNTIME_DIR/podman/podman.sock"
            if [ -S "$DOCKER_SOCK" ]; then
              DOCKER_FLAGS+=(
                "-v" "$DOCKER_SOCK:/run/podman/podman.sock"
                "-e" "DOCKER_HOST=unix:///run/podman/podman.sock"
                "-e" "CONTAINER_HOST=unix:///run/podman/podman.sock"
              )
            else
              echo "sandbox: Podman socket not found at $DOCKER_SOCK (enable podman.socket user unit), skipping docker forwarding" >&2
            fi
          ''}

          TTY_FLAG=""
          if [ -t 0 ]; then
            TTY_FLAG="-t"
          fi

          WORKDIR="$(pwd)"
          PI_CONFIG="$(readlink -f "$HOME/.pi/agent")"

          # Detect repo root and mount it if different from workdir
          declare -a REPO_FLAGS=()
          REPO_ROOT="$(jj root 2>/dev/null)" || REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || true
          if [ -n "$REPO_ROOT" ] && [ "$REPO_ROOT" != "$WORKDIR" ]; then
            REPO_FLAGS+=("-v" "$REPO_ROOT:$REPO_ROOT")
          fi
          # jj workspaces store a relative path to the backing repo in .jj/repo
          if [ -f "$WORKDIR/.jj/repo" ]; then
            JJ_BACKING="$(cd "$WORKDIR/.jj" && readlink -f "$(cat repo)/../.." 2>/dev/null)" || true
            if [ -n "$JJ_BACKING" ] && [ "$JJ_BACKING" != "$WORKDIR" ] && [ "$JJ_BACKING" != "''${REPO_ROOT:-}" ]; then
              REPO_FLAGS+=("-v" "$JJ_BACKING:$JJ_BACKING")
            fi
          fi

          # testcontainers (requires forwardDocker + --no-firewall): the map-gw
          # pasta route (see tcNetwork) maps the deterministic gateway to
          # host-loopback, so we point testcontainers libraries at that gateway
          # and disable Ryuk/checks (Ryuk won't start cleanly under a forwarded
          # rootless podman socket).
          declare -a TC_FLAGS=()
          ${optionalString (cfg.forwardTestcontainers && cfg.forwardDocker) ''
            if [ "$NO_FIREWALL" = true ] && [ -S "$XDG_RUNTIME_DIR/podman/podman.sock" ]; then
              TC_FLAGS+=(
                "-e" "TESTCONTAINERS_HOST_OVERRIDE=10.200.200.2"
                "-e" "TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=$XDG_RUNTIME_DIR/podman/podman.sock"
                "-e" "TESTCONTAINERS_RYUK_DISABLED=true"
                "-e" "TESTCONTAINERS_CHECKS_DISABLED=true"
              )
            fi
          ''}

          declare -a MOUNT_FLAGS=()
          ${
            concatStringsSep "\n" (map (m: ''MOUNT_FLAGS+=(${escapeShellArg m})'') cfg.extraMounts)
          }

          declare -a HOSTCMD_FLAGS=()
          ${optionalString (cfg.hostCommands != {}) ''
            HOSTCMD_SOCK="$XDG_RUNTIME_DIR/pi-sandbox-hostcmd.sock"
            if [ -S "$HOSTCMD_SOCK" ]; then
              HOSTCMD_FLAGS+=("-v" "$HOSTCMD_SOCK:/run/pi-sandbox-hostcmd.sock")
            else
              echo "sandbox: host command socket not found, hostCommands unavailable" >&2
            fi
          ''}

          # Network mode: restricted netns (if available), none, or default pasta
          NETWORK_FLAGS=()
          RUN_PREFIX=(systemd-run --user --scope --slice=pi_sandbox --)
          ${
            if !cfg.networkAccess
            then ''
              NETWORK_FLAGS+=("--network" "none")
            ''
            else ''
              if [ "$NO_FIREWALL" = false ] && [ -e /run/netns/pi-restricted ]; then
                NETWORK_FLAGS+=("--network" "pasta:--address,10.200.100.1" "--dns" "10.200.1.2")
                RUN_PREFIX=(sudo "${nsenterWrapper}" systemd-run --user --scope --slice=pi_sandbox --)
              else
                NETWORK_FLAGS+=("--network" "${tcNetwork}")
              fi
            ''
          }

          declare -a PORT_FLAGS=()
          if [ ''${#PORTS[@]} -gt 0 ]; then
            PORT_FLAGS=("''${PORTS[@]}")
          fi

          # Start socat forwarders so localhost:<port> works on the host
          SOCAT_PIDS=()
          cleanup() {
            for pid in "''${SOCAT_PIDS[@]}"; do
              kill "$pid" 2>/dev/null || true
            done
          }
          trap cleanup EXIT

          for mapping in "''${HOST_PORTS[@]}"; do
            host_port="''${mapping%%:*}"
            container_port="''${mapping##*:}"
            socat "TCP-LISTEN:''${host_port},fork,reuseaddr" "TCP:10.200.1.2:''${container_port}" &
            SOCAT_PIDS+=($!)
          done

          # Build container command: copy home config, then run args or interactive bash
          # shellcheck disable=SC2016
          INIT='cp -rL /etc/homeConfig/. "$HOME/" 2>/dev/null; chmod -R u+w "$HOME/" 2>/dev/null; '

          if [ $# -eq 0 ]; then
            CONTAINER_CMD=("bash" "-c" "''${INIT}exec bash")
          else
            CONTAINER_CMD=("bash" "-c" "''${INIT}exec \"\$@\"" "--" "$@")
          fi

          "''${RUN_PREFIX[@]}" \
            podman run \
            --rm \
            -i $TTY_FLAG \
            --userns=keep-id \
            --cap-drop ALL \
            --security-opt no-new-privileges \
            --read-only \
            --mount type=tmpfs,destination=/tmp,tmpfs-size=53687091200,U=true \
            --mount type=tmpfs,destination=/home/sandbox,tmpfs-size=53687091200,U=true \
            "''${NETWORK_FLAGS[@]}" \
            -w "$WORKDIR" \
            -v "$WORKDIR":"$WORKDIR" \
            "''${REPO_FLAGS[@]+"''${REPO_FLAGS[@]}"}" \
            -v "$PI_CONFIG":/pi-config \
            ${concatStringsSep " " (mapAttrsToList (k: v: ''-e "${k}=${v}"'') cfg.extraEnv)} \
            "''${GPG_FLAGS[@]+"''${GPG_FLAGS[@]}"}" \
            "''${GIT_FLAGS[@]+"''${GIT_FLAGS[@]}"}" \
            "''${CLAUDE_FLAGS[@]+"''${CLAUDE_FLAGS[@]}"}" \
            "''${DOCKER_FLAGS[@]+"''${DOCKER_FLAGS[@]}"}" \
            "''${TC_FLAGS[@]+"''${TC_FLAGS[@]}"}" \
            "''${MOUNT_FLAGS[@]+"''${MOUNT_FLAGS[@]}"}" \
            "''${HOSTCMD_FLAGS[@]+"''${HOSTCMD_FLAGS[@]}"}" \
            "''${PORT_FLAGS[@]+"''${PORT_FLAGS[@]}"}" \
            "$IMAGE" \
            "''${CONTAINER_CMD[@]}"
        '';
      };
    in {
      home.packages = [sandbox];

      # Systemd user slice that constrains all pi-sandbox containers collectively.
      systemd.user.slices.pi_sandbox = {
        Unit = {Description = "Resource ceiling for all pi-sandbox containers";};
        Slice = {
          MemoryHigh = "18G";
          MemoryMax = "20G";
          MemorySwapMax = "2G";
          MemorySwappiness = 10;
          CPUQuota = "1500%";
        };
      };

      # Host command proxy daemon
      systemd.user.services.pi-sandbox-hostcmd = mkIf (cfg.hostCommands != {}) {
        Unit = {Description = "Host command proxy for pi-sandbox";};
        Service = {
          ExecStart = "${pi-sandbox.hostcmdDaemon}";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      # Rootless Podman API socket, so `docker`/`podman` in the sandbox can
      # talk to the host daemon. Mirrors the upstream podman.socket user unit.
      systemd.user.sockets.podman = mkIf cfg.forwardDocker {
        Unit = {Description = "Podman API Socket for user";};
        Socket = {
          ListenStream = ["%t/podman/podman.sock"];
          SocketMode = "0660";
        };
        Install = {
          WantedBy = ["sockets.target"];
        };
      };

      systemd.user.services.podman = mkIf cfg.forwardDocker {
        Unit = {
          Description = "Podman API Service";
          Requires = ["podman.socket"];
          After = ["podman.socket"];
        };
        Service = {
          Type = "exec";
          ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
        };
      };
    }
  );
}
