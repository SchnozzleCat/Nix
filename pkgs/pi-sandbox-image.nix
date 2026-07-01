{
  pkgs,
  lib ? pkgs.lib,
  hostCommands ? {},
}: let
  hostcmd = import ./pi-sandbox-hostcmd.nix {inherit pkgs hostCommands;};

  wrap = import ../home/utility/wrap.nix {inherit pkgs;};

  # Same wrapping pattern as home/terminal.nix — resolves LINEAR_API_KEY
  # from `pass` at invocation time, keeping it out of the environment that
  # the coding agent (pi) can see.
  linear-cli-wrapped = wrap {
    pkg = pkgs.linear-cli;
    bin = "linear";
    env = {
      LINEAR_API_KEY = "$(${pkgs.pass}/bin/pass pina/linear-api-key 2>/dev/null)";
    };
  };

  gh-wrapped = wrap {
    pkg = pkgs.gh;
    bin = "gh";
    env = {
      GH_TOKEN = "$(${pkgs.pass}/bin/pass pina/github 2>/dev/null)";
    };
  };

  piPkgUnwrapped = pkgs.pi-coding-agent.overrideAttrs (oldAttrs: rec {
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

  piPkg = wrap {
    pkg = piPkgUnwrapped;
    bin = "pi";
    env = {
      OPENCODE_API_KEY = "$(pass pina/opencode-api-key 2>/dev/null)";
    };
  };

  # Agent skills baked into the image
  skills = pkgs.symlinkJoin {
    name = "agent-skills";
    paths =
      [../home/config/skills]
      ++ import ../home/config/remote-agent-skills.nix {inherit pkgs;};
  };
  homeConfig = pkgs.buildEnv {
    name = "pi-sandbox-config";
    paths = [
      (pkgs.writeTextDir ".bashrc" ''
        eval "$(starship init bash)"
      '')
      (pkgs.writeTextDir ".config/starship.toml" ''
        palette = "custom"

        [container]
        format = "[$symbol sandbox]($style) "

        [palettes.custom]
      '')
      (pkgs.runCommand "pi-sandbox-skills" {} ''
        mkdir -p $out/.agents
        ln -s ${skills} $out/.agents/skills
      '')
    ];
  };
in {
  inherit piPkg piPkgUnwrapped;
  hostcmdDaemon = hostcmd.daemon;

  image = pkgs.dockerTools.buildImage {
    name = "pi-sandbox";
    tag = "latest";
    diskSize = 4096;

    copyToRoot = pkgs.buildEnv {
      name = "pi-sandbox-root";
      paths = with pkgs;
        [
          piPkg
          claude-code
          bashInteractive
          coreutils
          findutils
          git
          curl
          wget
          ripgrep
          fd
          jq
          nodejs
          python3
          python3Packages.uv
          gcc
          gnumake
          cmake
          diffutils
          patch
          unzip
          gzip
          bzip2
          xz
          zstd
          file
          which
          procs
          cacert
          iana-etc
          pass
          gnupg
          jujutsu
          gnugrep
          procps
          just
          gh-wrapped
          linear-cli-wrapped
          docker
          starship
          stdenv.cc.cc.lib
          dotnetCorePackages.sdk_10_0
          R
          icu.dev
          icu
          openssl.out
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXtst
          xorg.libXi
          fontconfig.lib
          jdk8
          maven
        ]
        ++ lib.optional (hostCommands != {}) hostcmd.wrappers;
      pathsToLink = ["/bin" "/lib" "/etc" "/share"];
    };

    runAsRoot = ''
      #!${pkgs.runtimeShell}
      mkdir -p /lib64 /usr/bin /etc/homeConfig
      ln -s /bin/env /usr/bin/env
      ln -s ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
      cp -rL ${homeConfig}/. /etc/homeConfig/
      echo "root:x:0:0::/root:/bin/bash" >> /etc/passwd
      echo "root:x:0:" >> /etc/group
      echo "sandbox:x:1000:1000::/home/sandbox:/bin/bash" >> /etc/passwd
      echo "sandbox:x:1000:" >> /etc/group
    '';

    config = {
      Env = [
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "NODE_OPTIONS=--use-openssl-ca"
        "PATH=/bin"
        "HOME=/home/sandbox"
        "PI_CODING_AGENT_DIR=/pi-config"
        "TMPDIR=/tmp"
        "LD_LIBRARY_PATH=/lib"
      ];
      WorkingDir = "/";
    };
  };
}
