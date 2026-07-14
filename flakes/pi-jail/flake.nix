{
  # --- 1. Inputs: just our dependencies ---
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    jail-nix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      jail = jail-nix.lib.init pkgs;

      # Pi is packaged in nixpkgs as `pi-coding-agent`. Pin it to the version
      # the rest of the host setup expects so behaviour stays consistent.
      pi-pkg = pkgs.pi-coding-agent.overrideAttrs (oldAttrs: rec {
        version = "0.79.8";
        src = oldAttrs.src.override {
          tag = "v${version}";
          hash = "sha256-eH1+vHrKBu1GcUXnTdvRtNuLuf0EdReAnFit8UqiXB4=";
        };
        npmDeps = pkgs.fetchNpmDeps {
          name = "pi-coding-agent-${version}-npm-deps";
          inherit src;
          hash = "sha256-xrTpu4TkRmlflg7pMaw/QVsN+poQ41slVA5PET+NDoI=";
        };
      });

      # Common packages available to the jailed pi agent.
      #
      # Lifted from the existing pi-sandbox container image
      # (pkgs/pi-sandbox-image.nix) but stripped of anything too specific:
      #   - the other agents (claude-code)
      #   - host secret plumbing (pass, gnupg, gh/linear wrappers)
      #   - host daemon forwarding (docker)
      #   - the container prompt (starship)
      #   - language SDKs only some projects need (R, dotnet, jdk, maven)
      #   - GUI/godot libs (xorg.*, fontconfig.lib)
      # What's left is the general-purpose dev toolbelt pi tends to reach for.
      commonPkgs = with pkgs; [
        bashInteractive
        coreutils
        findutils
        gnugrep
        gawk
        procps
        which
        file

        # networking / data
        curl
        wget
        jq
        cacert
        iana-etc

        # vcs & task runners
        git
        jujutsu
        just

        # containers: CLIs to drive the host's podman/docker socket, which is
        # bind-mounted into the jail by `docker-socket` in commonJailOptions.
        # `docker-client` is the docker CLI only (no daemon pulled in);
        # `podman` is the native client for the same socket.
        podman
        docker-client

        # search
        ripgrep
        fd

        # archives
        gzip
        bzip2
        xz
        zstd
        unzip
        gnutar

        # diff / patch
        diffutils
        patch

        # runtime libs a fair number of tools dlopen
        stdenv.cc.cc.lib
        icu
        openssl.out
      ];

      # Resolve a secret from the host's `pass` store at the moment the
      # jailed-pi wrapper script runs -- i.e. on the host, *before* bwrap
      # starts -- and inject it into the jail via `--setenv`.
      #
      # This mirrors the old pi-sandbox-image `wrap` pattern: pi sees the
      # resolved value but `pass`/`gnupg` themselves never enter the jail, so
      # the agent can't decrypt anything else. `pass` is invoked by absolute
      # nix-store path (so the wrapper doesn't depend on the host's $PATH) and
      # inherits $GNUPGHOME / $PASSWORD_STORE_DIR (or their defaults) from the
      # invoking shell, exactly like an interactive `pass` call. `|| true`
      # keeps the wrapper alive under `set -e` when a key is absent.
      pass-env = name: passPath:
        jail.combinators.compose [
          (jail.combinators.add-runtime ''
            # shellcheck disable=SC2034  # consumed below via unsafe-add-raw-args --setenv
            ${name}="$( ${pkgs.pass}/bin/pass ${passPath} 2>/dev/null )" || true
          '')
          # `${name}` interpolates at build time to the variable name, and
          # `''$` is the Nix indented-string escape for a literal `$` (a bare
          # `$$` would NOT escape -- it renders literally as `$${name}`, and
          # bash then expands `$$` to its PID, corrupting the key). So bwrap
          # receives e.g.
          #   --setenv OPENCODE_API_KEY "$OPENCODE_API_KEY"
          # which bash expands against the var set by add-runtime above.
          (jail.combinators.unsafe-add-raw-args ''--setenv ${name} "''$${name}"'')
        ];

      # Common sandbox options shared by every jailed pi invocation.
      #
      # jail.nix's `base` permission runs `bwrap --clearenv` and forwards only
      # LANG/HOME/TERM/PATH, so anything pi's model config references via
      # `$VAR` (API keys, proxy, CA bundle) must be re-injected here or the
      # first model request hangs until it times out.
      commonJailOptions = with jail.combinators; [
        network
        time-zone
        no-new-session
        mount-cwd

        # Credentials resolved from the host pass store at invocation time.
        (pass-env "OPENCODE_API_KEY" "opencode-api-key")
        (pass-env "BRAVE_SEARCH_API_KEY" "brave-search-api-key")

        # Forward optional proxy vars if the host exports them (no-op if unset).
        (try-fwd-env "HTTPS_PROXY")
        (try-fwd-env "HTTP_PROXY")
        (try-fwd-env "NO_PROXY")

        # TLS: the `network` combinator bind-mounts /etc/ssl into the jail, so
        # /etc/ssl/certs/ca-bundle.crt exists inside -- but nixpkgs' Node is
        # NOT patched to know that path, and its compiled-in Mozilla CAs can't
        # verify the model endpoints (verified empirically against
        # api.anthropic.com: built-in CAs fail with
        # UNABLE_TO_GET_ISSUER_CERT_LOCALLY). OpenSSL honors SSL_CERT_FILE even
        # in Node's default built-in-CA mode, so this alone is sufficient;
        # `--use-openssl-ca` is deliberately omitted (redundant with
        # SSL_CERT_FILE, and harmful without it).
        (set-env "SSL_CERT_FILE" "/etc/ssl/certs/ca-bundle.crt")

        # Let pi remember settings, sessions, installed extensions/skills, and
        # npm/git caches between runs.
        (readwrite (noescape "~/.pi"))
        (readwrite (noescape "~/.cache"))

        # Forward the host's podman/docker socket into the jail so pi can run
        # `docker` / `podman` against the host daemon.
        #
        # We bind the *real* socket at /run/podman/podman.sock, not the
        # /run/docker.sock symlink that `dockerSocket.enable` creates: bwrap
        # would bind the symlink itself, and its target (/run/podman/...)
        # doesn't exist inside the jail, leaving a dangling link. `try-rw-bind`
        # (--bind-try) tolerates the socket being absent -- e.g. if
        # podman.socket hasn't been started yet -- so pi still launches; docker
        # commands then just fail with ECONNREFUSED instead of taking the whole
        # jail down.
        #
        # Access caveat: bwrap unshares the user namespace and maps only the
        # primary gid (it writes "deny" to setgroups), so linus's `podman`
        # *supplementary* group membership does NOT apply inside the jail. The
        # companion host change in configuration.nix re-targets the podman
        # socket's group to `users` (linus's primary gid, which bwrap DOES map)
        # so connect() succeeds. Without that, the bind is visible but every
        # request returns EACCES.
        (try-rw-bind "/run/podman/podman.sock" "/run/podman/podman.sock")
        (set-env "DOCKER_HOST" "unix:///run/podman/podman.sock")
        (set-env "CONTAINER_HOST" "unix:///run/podman/podman.sock")
      ];

      # --- 2. The Sandbox ---
      #
      # `extraCombinators` lets a consuming devshell inject project-specific
      # jail combinators (extra readwrite mounts, env, capabilities, etc.)
      # without redefining the common baseline.
      # `extensionPackages` adds pi extension *packages* (store paths that
      # are directories with a `package.json` `pi` manifest, plus the
      # `node_modules` they need) to every jailed pi invocation. Each is
      # passed to pi via `pi -e <store path>`, so pi loads it through its
      # package rules and registers the bundled tools/commands without us
      # having to touch the user's mutable `~/.pi/agent/settings.json`.
      #
      # Mechanism: we swap pi-pkg for a tiny `writeShellApplication` wrapper
      # whose `text` interpolates the real pi binary path and each extension
      # package's store path. jail.nix's `bind-nix-store-runtime-closure`
      # scans that text for store paths and bind-mounts the whole runtime
      # closure (pi + every extension package + their node_modules) into the
      # sandbox, so the wrapper can `exec` pi and `-e` the packages from
      # inside the jail without anything extra on `$PATH`.
      makeJailedPi = {
        name ? "pi",
        extraPkgs ? [],
        extraCombinators ? [],
        extensionPackages ? [],
      }: let
        extArgs =
          pkgs.lib.concatMapStringsSep " "
          (p: "-e ${p}")
          extensionPackages;
        program =
          if extensionPackages == []
          then pi-pkg
          else
            pkgs.writeShellApplication {
              inherit name;
              # Keep pi itself in the wrapper's closure even if a future
              # change stops interpolating the path into `text`.
              runtimeInputs = [pi-pkg];
              text = ''exec ${pkgs.lib.getExe pi-pkg} ${extArgs} "$@"'';
            };
      in
        jail name program (with jail.combinators; (
          commonJailOptions
          ++ extraCombinators
          ++ [
            (add-pkg-deps commonPkgs)
            (add-pkg-deps extraPkgs)
          ]
        ));
    in {
      lib = {
        inherit makeJailedPi;
      };

      # Expose the derived package set too, in case a devshell wants to pull
      # the pinned pi or the common package list directly.
      packages = {
        inherit pi-pkg;
        default = pi-pkg;
      };

      # --- 3. Putting it all together in the dev shell ---
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nixd # a little something for the editor

          (makeJailedPi {})
        ];
      };
    });
}
