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

      envVars = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {OPENCODE_API_KEY = "pina/opencode-api-key";};
        description = mdDoc "Attrset of ENV_VAR_NAME = pass-path pairs. Resolved at runtime via `pass` and passed inline to the pi command (not as container env vars, so other processes in the container cannot see them).";
      };

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
        description = mdDoc "Extra env vars to pass through to the container as static values (passed inline, not as container env vars).";
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
      wrapper = pkgs.writeShellApplication {
        name = "pi";
        runtimeInputs = [pkgs.podman pkgs.pass pkgs.coreutils pkgs.gnupg];
        text = ''
          IMAGE="pi-sandbox:latest"
          IMAGE_PATH="${piImage}"

          # Ensure the image is loaded into podman
          if ! podman image exists "$IMAGE" 2>/dev/null; then
            echo "Loading pi-sandbox container image..." >&2
            if ! podman load < "$IMAGE_PATH" >/dev/null; then
              echo "pi-sandbox: failed to load container image, aborting" >&2
              exit 1
            fi
          fi

          # Resolve env vars from pass (passed inline to the pi command,
          # not as container-level env vars, so other processes cannot see them)
          declare -a ENV_INLINE=()
          ${
            concatStringsSep "\n" (mapAttrsToList (var: passPath: ''
              KEY="$(${pkgs.pass}/bin/pass ${escapeShellArg passPath} 2>/dev/null)" || KEY=""
              if [ -n "$KEY" ]; then
                ENV_INLINE+=("${var}=$KEY")
              fi
            '') cfg.envVars)
          }

          ${
            concatStringsSep "\n" (mapAttrsToList (var: val: ''
              ENV_INLINE+=("${var}=${escapeShellArg val}")
            '') cfg.extraEnv)
          }

          # Forward ~/.gitconfig if enabled
          declare -a GIT_FLAGS=()
          ${optionalString cfg.forwardGitConfig ''
            if [ -f "$HOME/.config/git/config" ]; then
              GIT_FLAGS+=("-v" "$HOME/.config/git/config:/home/developer/.config/git/config:ro")
            fi
          ''}

          # Forward GPG agent and password store so `pass` works inside the container.
          # This allows the linear-cli wrapper (and interactive use) to resolve secrets
          # via the YubiKey-backed GPG agent on the host.
          declare -a GPG_FLAGS=()
          ${optionalString cfg.forwardGpg ''
            ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent 2>/dev/null || true
            GPG_SOCKET="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket)"

            KEYBOXD_SOCKET="$(${pkgs.gnupg}/bin/gpgconf --list-dirs keyboxd-socket)"

            if [ -S "$GPG_SOCKET" ] && [ -d "$HOME/.gnupg" ] && [ -d "$HOME/.password-store" ]; then
              GPG_FLAGS+=(
                "-v" "$HOME/.gnupg:/home/developer/.gnupg:ro"
                "-v" "$GPG_SOCKET:/home/developer/.gnupg/S.gpg-agent"
                "-v" "$HOME/.password-store:/home/developer/.password-store:ro"
              )

              # Forward keyboxd socket if it exists (GPG 2.4+ uses keyboxd for key storage)
              if [ -S "$KEYBOXD_SOCKET" ]; then
                GPG_FLAGS+=("-v" "$KEYBOXD_SOCKET:/home/developer/.gnupg/S.keyboxd")
              fi
              ENV_INLINE+=("GNUPGHOME=/home/developer/.gnupg")
              ENV_INLINE+=("PASSWORD_STORE_DIR=/home/developer/.password-store")
            else
              echo "pi-sandbox: GPG agent socket not found or missing ~/.gnupg / ~/.password-store, skipping GPG forwarding" >&2
            fi
          ''}

          # Allocate TTY only when running interactively
          TTY_FLAG=""
          if [ -t 0 ]; then
            TTY_FLAG="-t"
          fi

          WORKDIR="$(pwd)"

          # Resolve symlinks for Nix-managed config directory
          PI_CONFIG="$(readlink -f "$HOME/.pi/agent")"

          # Collect extra mount flags
          declare -a MOUNT_FLAGS=()
          ${
            concatStringsSep "\n" (map (m: ''MOUNT_FLAGS+=(${escapeShellArg m})'') cfg.extraMounts)
          }

          # Bind-mount host command socket if hostCommands are configured
          declare -a HOSTCMD_FLAGS=()
          ${optionalString (cfg.hostCommands != {}) ''
            HOSTCMD_SOCK="$XDG_RUNTIME_DIR/pi-sandbox-hostcmd.sock"
            if [ -S "$HOSTCMD_SOCK" ]; then
              HOSTCMD_FLAGS+=("-v" "$HOSTCMD_SOCK:/run/pi-sandbox-hostcmd.sock")
            else
              echo "pi-sandbox: host command socket not found, hostCommands unavailable" >&2
            fi
          ''}

          # Network mode: restricted netns (if available), none, or default pasta
          NETWORK_FLAGS=()
          RUN_PREFIX=(systemd-run --user --scope --slice=pi_sandbox --)
          ${
            if !cfg.networkAccess then ''
              NETWORK_FLAGS+=("--network" "none")
            '' else ''
              if [ -e /run/netns/pi-restricted ]; then
                NETWORK_FLAGS+=("--network" "pasta:--address,10.200.100.1" "--dns" "10.200.1.2")
                RUN_PREFIX=(sudo "${nsenterWrapper}" systemd-run --user --scope --slice=pi_sandbox --)
              else
                NETWORK_FLAGS+=("--network" "pasta")
              fi
            ''
          }

          # Run the container under a systemd slice so all pi-sandbox containers
          # share a collective resource ceiling (memory, CPU, swap).
          #   - env vars passed inline via `env` (not as container env vars via -e)
          #   - GPG agent + password store forwarded so `pass` works inside the container
          "''${RUN_PREFIX[@]}" \
            podman run \
            --rm \
            -i $TTY_FLAG \
            --userns=keep-id \
            --cap-drop ALL \
            --security-opt no-new-privileges \
            --read-only \
            --tmpfs /tmp:rw,size=1g \
            --pids-limit 512 \
            "''${NETWORK_FLAGS[@]}" \
            -w "$WORKDIR" \
            -v "$WORKDIR":"$WORKDIR" \
            -v "$PI_CONFIG":/pi-config \
            "''${GPG_FLAGS[@]+"''${GPG_FLAGS[@]}"}" \
            "''${GIT_FLAGS[@]+"''${GIT_FLAGS[@]}"}" \
            "''${MOUNT_FLAGS[@]+"''${MOUNT_FLAGS[@]}"}" \
            "''${HOSTCMD_FLAGS[@]+"''${HOSTCMD_FLAGS[@]}"}" \
            "$IMAGE" \
            env "''${ENV_INLINE[@]+"''${ENV_INLINE[@]}"}" pi "$@"
        '';
      };
    in {
      home.packages = [wrapper];

      # Systemd user slice that constrains all pi-sandbox containers collectively.
      systemd.user.slices.pi_sandbox = {
        Unit = { Description = "Resource ceiling for all pi-sandbox containers"; };
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
        Unit = { Description = "Host command proxy for pi-sandbox"; };
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
