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
          while [ $# -gt 0 ]; do
            case "$1" in
              -p)
                PORTS+=("-p" "$2")
                HOST_PORTS+=("$2")
                shift 2
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
              if [ -e /run/netns/pi-restricted ]; then
                NETWORK_FLAGS+=("--network" "pasta:--address,10.200.100.1" "--dns" "10.200.1.2")
                RUN_PREFIX=(sudo "${nsenterWrapper}" systemd-run --user --scope --slice=pi_sandbox --)
              else
                NETWORK_FLAGS+=("--network" "pasta")
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
    }
  );
}
