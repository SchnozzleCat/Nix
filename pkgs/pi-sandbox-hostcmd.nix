{
  pkgs,
  hostCommands,
}: let
  inherit (builtins) toJSON attrNames;

  # Build the whitelist JSON baked into the daemon
  whitelist =
    builtins.mapAttrs (name: cfg: {
      command = cfg.command;
      allowedArgs = cfg.allowedArgs;
    })
    hostCommands;

  # Host-side daemon: validates requests against the whitelist, executes allowed commands
  daemon = pkgs.writeScript "pi-sandbox-hostcmd-daemon" ''
    #!${pkgs.python3}/bin/python3
    import json, os, socket, subprocess, sys

    WHITELIST = json.loads(${toJSON (toJSON whitelist)})
    SOCKET_PATH = os.path.join(os.environ["XDG_RUNTIME_DIR"], "pi-sandbox-hostcmd.sock")
    MAX_REQUEST = 65536
    TIMEOUT = 30

    def matches_prefix(args, pattern):
        if len(args) < len(pattern):
            return False
        return all(p == "*" or p == a for p, a in zip(pattern, args))

    def is_allowed(cmd, args):
        if cmd not in WHITELIST:
            return False
        prefixes = WHITELIST[cmd]["allowedArgs"]
        if not prefixes:
            return len(args) == 0
        return any(matches_prefix(args, p) for p in prefixes)

    def handle(conn):
        try:
            data = conn.recv(MAX_REQUEST).decode()
            if not data:
                return
            req = json.loads(data.strip())
            cmd_name = req.get("cmd", "")
            args = req.get("args", [])
            if not isinstance(args, list) or not all(isinstance(a, str) for a in args):
                resp = {"exit_code": -1, "stdout": "", "stderr": "invalid args"}
            elif not is_allowed(cmd_name, args):
                resp = {"exit_code": -1, "stdout": "", "stderr": "command not allowed: " + cmd_name + " " + " ".join(args)}
            else:
                binary = WHITELIST[cmd_name]["command"]
                try:
                    result = subprocess.run(
                        [binary] + args,
                        capture_output=True, text=True, timeout=TIMEOUT
                    )
                    resp = {"exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr}
                except subprocess.TimeoutExpired:
                    resp = {"exit_code": -1, "stdout": "", "stderr": "command timed out"}
                except Exception as e:
                    resp = {"exit_code": -1, "stdout": "", "stderr": str(e)}
        except Exception as e:
            resp = {"exit_code": -1, "stdout": "", "stderr": "protocol error: " + str(e)}
        conn.sendall((json.dumps(resp) + "\n").encode())

    def main():
        if os.path.exists(SOCKET_PATH):
            os.unlink(SOCKET_PATH)
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.bind(SOCKET_PATH)
        os.chmod(SOCKET_PATH, 0o600)
        sock.listen(4)
        print(f"pi-sandbox-hostcmd: listening on {SOCKET_PATH}", file=sys.stderr)
        while True:
            conn, _ = sock.accept()
            try:
                handle(conn)
            except Exception as e:
                print(f"pi-sandbox-hostcmd: error: {e}", file=sys.stderr)
            finally:
                conn.close()

    if __name__ == "__main__":
        main()
  '';

  # Per-command wrapper client script (runs inside the container)
  mkWrapper = name:
    pkgs.writeScriptBin name ''
      #!${pkgs.python3}/bin/python3
      import json, os, socket, sys

      SOCKET_PATH = "/run/pi-sandbox-hostcmd.sock"

      def main():
          args = sys.argv[1:]
          req = json.dumps({"cmd": ${toJSON name}, "args": args}) + "\n"

          if not os.path.exists(SOCKET_PATH):
              print(f"${name}: host command socket not available", file=sys.stderr)
              sys.exit(127)

          sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
          sock.connect(SOCKET_PATH)
          sock.sendall(req.encode())

          data = b""
          while True:
              chunk = sock.recv(65536)
              if not chunk:
                  break
              data += chunk
          sock.close()

          resp = json.loads(data.decode())
          if resp.get("stdout"):
              sys.stdout.write(resp["stdout"])
          if resp.get("stderr"):
              sys.stderr.write(resp["stderr"])
          sys.exit(resp.get("exit_code", 1))

      if __name__ == "__main__":
          main()
    '';

  # Combine all wrapper scripts into a single derivation
  wrappers = pkgs.symlinkJoin {
    name = "pi-sandbox-hostcmd-wrappers";
    paths = map mkWrapper (attrNames hostCommands);
  };
in {
  inherit daemon wrappers;
}
