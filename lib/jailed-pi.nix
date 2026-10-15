# makeJailedPi: a bwrap-sandboxed `pi` coding agent.
#
# Single source of truth, re-exported two ways by the root flake:
#
#   - pkgs.makeJailedPi { ... }        (via overlays.additions; use this
#     wherever a host/home-manager `pkgs` is already in scope, e.g.
#     home/linus.nix)
#   - outputs.lib.makeJailedPi pkgs { ... }   (for anything outside an
#     overlay-applied package set: devshells, or an external flake/direnv
#     .envrc, e.g.
#
#         inputs.dotfiles = { url = "github:SchnozzleCat/dotfiles"; };
#         outputs = { self, nixpkgs, dotfiles, ... }: let
#           pkgs = nixpkgs.legacyPackages.${system};
#         in {
#           devShells.${system}.default = pkgs.mkShell {
#             packages = [
#               # default invocation: `pi` with the default package set
#               (dotfiles.lib.makeJailedPi pkgs {})
#               # or with project-specific extras
#               (dotfiles.lib.makeJailedPi pkgs {extraPkgs = [pkgs.rustc];})
#             ];
#           };
#         }
#
#     )
#
# The default invocation (`pi`) runs the default package set defined below;
# extend it per-consumer via extraPkgs / extraCombinators / extensionPackages /
# nugetPackages.
#
# NOTE: pass the package set you want INSIDE the jail. The host's
# overlay-applied pkgs is the usual (and most consistent) choice.
{
  pkgs,
  lib,
  jail-nix,
}: let
  jail = jail-nix.lib.init pkgs;

  # Pi is packaged in nixpkgs as `pi-coding-agent`. nixos-unstable now
  # ships 0.84.4, the version the rest of the host setup expects, so we
  # use it directly. NOTE: if you ever re-pin to a newer version than
  # nixpkgs ships, the override must ALSO provide `modelData` (the
  # gitignored generated provider catalog fetched from the matching
  # @earendil-works/pi-ai npm tarball) and match whatever the current
  # nixpkgs recipe's buildPhase/postInstall expect -- the recipe changes
  # between upstream versions, so a bare version/src/npmDeps override
  # will break the build (see the 0.80.x -> 0.84.4 packaging rework).
  pi-pkg = pkgs.pi-coding-agent;

  # Common packages available to the jailed pi agent.
  #
  # Lifted from the existing pi-sandbox container image
  # (pkgs/pi-sandbox-image.nix) but stripped of anything too specific:
  #   - the other agents (claude-code)
  #   - host secret plumbing (pass, gnupg, gh/linear wrappers)
  #   - host daemon forwarding (docker)
  #   - the container prompt (starship)
  #   - language SDKs only some projects need (R, dotnet, jdk, maven)
  #   - GUI libs (xorg.*) -- the godot *build* libraries (xorg.*, wayland,
  #     fontconfig, ...) are re-added below as godotBuildLibs/godotBuildEnv
  #     so pi can compile Godot from source in the sandbox
  # What's left is the general-purpose dev toolbelt pi tends to reach for.
  # The godot build libs are appended at the end via godotBuildDeps.
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

    # .NET SDKs 10/9/8 combined (see dotnet-combined / combinedSdk below)
    combinedSdk
  ]
  ++ godotBuildDeps;

  # Godot from-source build environment. Mirrors the !isWindows
  # buildInputs / nativeBuildInputs of the custom fork packaging
  # (pkgs/godot4-mono-schnozzlecat/common.nix), so pi can configure and
  # compile Godot (scons from a source checkout) inside the jail.
  #
  # Build tools ...
  godotBuildTools = with pkgs; [
    scons
    pkg-config # linuxbsd detect.py discovers every system lib via pkg-config
    perl # source patches / SConstruct scripting
    python3 # build_scripts (mono glue/assemblies) + scons backend
    stdenv.cc # wrapped gcc/g++ (scons invokes it directly)
    wayland-scanner # wayland protocol codegen required by the wayland build
  ];

  # ... and the system libraries the engine links against. harfbuzz
  # matches the fork's "harfbuzz-icu" (raster + Cairo enabled -- required
  # by Godot 4.7's system-harfbuzz linkage -- plus ICU).
  godotBuildLibs = with pkgs;
    [
      embree
      enet
      freetype
      glslang
      graphite2
      icu
      libjpeg_turbo
      libtheora
      libwebp
      mbedtls
      miniupnpc
      openxr-loader
      pcre2
      recastnavigation
      wslay
      zstd
      (harfbuzz.override {
        withRaster = true;
        withCairo = true;
        withIcu = true;
      })
    ]
    ++ [
      alsa-lib
      dbus # screensaver / portal desktop settings
      fontconfig # system fonts
      glib
      libGL
      libpulseaudio
      libdecor
      libxkbcommon
      speechd-minimal # text-to-speech
      udev # gamepad connection callbacks
      vulkan-loader
      wayland
    ]
    ++ [ # x11
      libX11
      libXcursor
      libXext
      libXfixes
      libXi
      libXinerama
      libXrandr
      libXrender
    ];

  # Dev outputs of ALL godot build libs merged into ONE prefix, so every
  # header and .pc file is reachable from a single PKG_CONFIG_PATH (the
  # jail has no stdenv setup hooks to lay them out per-package).
  godotBuildEnv = pkgs.buildEnv {
    name = "godot-build-env";
    paths = map lib.getDev godotBuildLibs;
    pathsToLink = ["/lib" "/include" "/share"];
  };

  # Dropped into the jail via add-pkg-deps below: binds the merged env
  # (whose closure carries every dev output the symlinks point at) and
  # puts its bin dir on $PATH.
  godotBuildDeps = godotBuildTools ++ [godotBuildEnv];

  # Godot build-support jail options. The jail's base permission clears
  # the environment, so the discovery/linkage paths must be re-injected:
  #   - PKG_CONFIG_PATH: lets linuxbsd/detect.py find the system libs.
  #   - NIX_LDFLAGS: the cc-wrapper reads this at link time; -L exposes
  #     the merged lib dir (no setup hooks to do it), -rpath encodes it
  #     into the built binary so volk's dlopen("libvulkan.so.1") and
  #     friends resolve at runtime (the store-path patching the fork's
  #     derivation applies only exists in that derivation's build).
  #   - the trailing -lharfbuzz-raster mirrors the fork's preBuild
  #     (Godot 4.7 + system harfbuzz needs explicit raster linkage).
  godotJailOptions = with jail.combinators; [
    (set-env "PKG_CONFIG_PATH" "${godotBuildEnv}/lib/pkgconfig:${godotBuildEnv}/share/pkgconfig")
    (set-env "NIX_LDFLAGS" "-L${godotBuildEnv}/lib -rpath ${godotBuildEnv}/lib -lharfbuzz-raster")
  ];

  # Combined .NET SDKs (10/9/8). The real runtime tree (host/fxr, shared,
  # packs, ...) lives at "${dotnet-combined}/share/dotnet" (see nixpkgs'
  # combine-packages.nix). combinedSdk is just a named env around it for
  # PATH exposure; because buildEnv only links /bin by default, anything
  # needing the runtime tree directly must reference dotnet-combined.
  # Framework-dependent apphost binaries are exec'd *around* dotnet (e.g.
  # `aspire run` spawns the AppHost directly, so the bin/dotnet wrapper's
  # env never reaches it) -- they need DOTNET_ROOT injected explicitly;
  # see the set-env combinator in commonJailOptions below.
  dotnet-combined =
    with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_10_0
        sdk_9_0
        sdk_8_0
      ];

  combinedSdk = pkgs.buildEnv {
    name = "combinedSdk";
    paths = [dotnet-combined];
  };

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

    # .NET: framework-dependent apphost binaries (e.g. the AppHost that
    # `aspire run` execs directly) search DOTNET_ROOT for host/fxr and the
    # shared runtimes. The bin/dotnet wrapper only sets up env for its own
    # process, so inject the real runtime tree here.
    (set-env "DOTNET_ROOT" "${dotnet-combined}/share/dotnet")

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

  # The sandbox builder.
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
  #
  # `nugetPackages` exposes NuGet artifacts (packages exposing a
  # `share/nuget` layout, e.g. the custom godot-mono fork) to the dotnet
  # toolchain inside the jail: the custom Godot.NET.Sdk / GodotSharp
  # nupkgs become restorable, so pi can build C# Godot projects that
  # target the fork's versioned SDK. See `nugetBundle` below.
in {
  name ? "pi",
  extraPkgs ? [],
  extraCombinators ? [],
  extensionPackages ? [],
  nugetPackages ? [],
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

  # Bundle containing ONLY the NuGet artifacts of the packages passed via
  # `nugetPackages` (e.g. the custom godot-mono fork). Layout (bound
  # read-only at `/nuget` inside the jail):
  #
  #   /nuget/packages/     extracted package trees (NUGET_FALLBACK_PACKAGES)
  #   /nuget/source/       flat folder of .nupkg files (NuGet package source)
  #   /nuget/NuGet.Config  user-level config pointing at /nuget/source
  #
  # The contents are dereference-copied on purpose: the godot nuget trees
  # are stitched together with store-path symlinks and the editor's
  # runtime closure is huge. Copying makes the bundle self-contained, so
  # the jail can ro-bind this ONE small store path instead of pulling the
  # whole godot editor closure into the sandbox.
  nugetBundle = pkgs.runCommand "${name}-nuget"
    # `name` is the wrapper's name ("pi"); the combinators below
    # interpolate this store path into the wrapper text.
    {}
    ''
      set -eu
      mkdir -p "$out"/nuget/source "$out"/nuget/packages
      for pkg in ${lib.concatStringsSep " " (map (p: "${p}") nugetPackages)}; do
        # `cp -rL` dereferences: the godot nuget trees are stitched
        # together with store symlinks, and the bundle must stay
        # self-contained (see above).
        if [ -d "$pkg"/share/nuget/packages ]; then
          cp -rL "$pkg"/share/nuget/packages/. "$out"/nuget/packages/
        fi
        # Flatten every .nupkg the package ships: `share/nuget/source`
        # (the godot build moves GodotSharp/Tools/nupkgs there) plus
        # any libexec subdir shipping its own set (e.g. the locally
        # versioned Godot.NET.Sdk nupkgs pushed via --push-nupkgs-local).
        for dir in "$pkg"/share/nuget/source "$pkg"/libexec; do
          [ -d "$dir" ] || continue
          find "$dir" -type f -name '*.nupkg' \
            -exec cp {} "$out"/nuget/source/ \;
        done
      done
      cat >"$out"/nuget/NuGet.Config <<'EOF'
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
          <add key="jail-godot-nuget" value="/nuget/source" />
        </packageSources>
      </configuration>
      EOF
    '';

  # Wire the nuget bundle into the jail's dotnet toolchain.
  # `set-env` can only inject build-time literals, so the two runtime
  # pieces (per-user NUGET_PACKAGES under the rw-mounted ~/.cache, and
  # the NuGet.Config inside the ephemeral jail $HOME) run on the host
  # right before bwrap starts and append themselves via RUNTIME_ARGS,
  # mirroring the pass-env trick below.
  nugetJailOptions =
    lib.optionals (nugetPackages != [])
    (with jail.combinators; [
      # The bundle contains ONLY nuget artifacts, so a plain ro-bind
      # (no runtime-closure binding) is enough; nothing inside it needs
      # other store paths because everything was dereference-copied.
      (ro-bind "${nugetBundle}/nuget" "/nuget")

      # Offline restore source for the custom (versioned) SDK packages.
      (set-env "NUGET_FALLBACK_PACKAGES" "/nuget/packages/")

      # User-level NuGet.Config inside the ephemeral jail home. bwrap's
      # `--dir` creates the leading dirs in the (tmpfs) home before the
      # ro-bind mounts the config file into place.
      (compose [
        (add-runtime ''
          RUNTIME_ARGS+=(
            --dir "$HOME/.nuget"
            --dir "$HOME/.nuget/NuGet"
            --ro-bind ${nugetBundle}/nuget/NuGet.Config "$HOME/.nuget/NuGet/NuGet.Config"
          )
        '')
      ])

      # Persist the dotnet global packages folder in ~/.cache (bound
      # read-write by commonJailOptions) so restore results survive
      # across jail sessions.
      (compose [
        (add-runtime ''
          NUGET_PACKAGES="$HOME"/.cache/nuget/packages
        '')
        (unsafe-add-raw-args ''--setenv NUGET_PACKAGES "''$NUGET_PACKAGES"'')
      ])
    ]);
in
  jail name program (with jail.combinators; (
    commonJailOptions
    ++ nugetJailOptions
    ++ godotJailOptions
    ++ extraCombinators
    ++ [
      (add-pkg-deps commonPkgs)
      (add-pkg-deps extraPkgs)
    ]
  ))
