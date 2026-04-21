{pkgs}:
pkgs.writeShellScript "pi-sandbox-nsenter" ''
  set -euo pipefail
  if [ -z "''${SUDO_USER:-}" ]; then
    echo "pi-sandbox-nsenter: must be run via sudo" >&2
    exit 1
  fi
  CALLER_UID=$(${pkgs.coreutils}/bin/id -u "$SUDO_USER")
  export XDG_RUNTIME_DIR="/run/user/$CALLER_UID"
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$CALLER_UID/bus"
  exec ${pkgs.util-linux}/bin/nsenter --net=/run/netns/pi-restricted -- \
    sudo -u "$SUDO_USER" \
      XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
      DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
      -- "$@"
''
