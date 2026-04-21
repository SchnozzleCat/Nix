{pkgs, lib ? pkgs.lib, hostCommands ? {}}: let
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

  piPkg = pkgs.pi-coding-agent.overrideAttrs (oldAttrs: rec {
    version = "0.67.68";
    src = oldAttrs.src.override {
      tag = "v${version}";
      hash = "sha256-1k9tHb5Dle37a5qHm8xT14vI5cQZOb8ASGQ1KxzPCr4=";
    };
    npmDeps = pkgs.fetchNpmDeps {
      name = "pi-coding-agent-${version}-npm-deps";
      inherit src;
      hash = "sha256-xQQZECkDuiCdu0FlKbAKgk6EatLf2jMIXKDfRRwN/gA=";
    };
  });

  # Agent skills baked into the image
  skills = pkgs.symlinkJoin {
    name = "agent-skills";
    paths =
      [../home/config/skills]
      ++ import ../home/config/remote-agent-skills.nix {inherit pkgs;};
  };
in {
  inherit piPkg;
  hostcmdDaemon = hostcmd.daemon;

  image = pkgs.dockerTools.buildImage {
    name = "pi-sandbox";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "pi-sandbox-root";
      paths = with pkgs; [
        piPkg
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
        gh-wrapped
        linear-cli-wrapped
      ] ++ lib.optional (hostCommands != {}) hostcmd.wrappers;
      pathsToLink = ["/bin" "/lib" "/etc" "/share"];
    };

    runAsRoot = ''
      #!${pkgs.runtimeShell}
      mkdir -p /home/developer/.agents/skills /etc/ssl/certs /lib64
      # Deno-compiled binaries (like linear-cli) hardcode /lib64/ld-linux-x86-64.so.2
      # as their ELF interpreter, which doesn't exist in this container. Symlink it
      # to the nix store glibc so they can run.
      ln -s ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
      chmod 755 /home/developer
      ${pkgs.findutils}/bin/find ${skills} -mindepth 1 -maxdepth 1 -exec ln -s {} /home/developer/.agents/skills/ \;
      echo "root:x:0:0::/root:/bin/bash" >> /etc/passwd
      echo "root:x:0:" >> /etc/group
      echo "developer:x:1000:1000::/home/developer:/bin/bash" >> /etc/passwd
      echo "developer:x:1000:" >> /etc/group
    '';

    config = {
      Env = [
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "NODE_OPTIONS=--use-openssl-ca"
        "PATH=/bin"
        "HOME=/home/developer"
        "PI_CODING_AGENT_DIR=/pi-config"
        "TMPDIR=/tmp"
      ];
      WorkingDir = "/";
    };
  };
}
