{
  description = "Safe containerized dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    image = pkgs.dockerTools.buildImage {
      name = "safe-run";
      tag = "latest";

      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = [
          pkgs.nodejs
          pkgs.bash
          pkgs.coreutils
          pkgs.cacert
        ];
        pathsToLink = ["/bin"];
      };

      config = {
        WorkingDir = "/workspace";
        Cmd = ["bash"];
        Env = ["SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"];
      };
    };

    runScript = pkgs.writeShellScriptBin "safe-run" ''
      set -euo pipefail

      podman load -i ${image}

      podman run --rm -it \
        -v "$PWD":/workspace:Z \
        -w /workspace \
        --userns=keep-id \
        --cap-drop=ALL \
        --security-opt=no-new-privileges \
        --pids-limit=256 \
        --memory=1g \
        --read-only \
        --tmpfs /tmp \
        safe-run:latest \
        "$@"
    '';
  in {
    packages.${system}.image = image;

    apps.${system}.safe-run = {
      type = "app";
      program = "${runScript}/bin/safe-run";
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [runScript];
    };
  };
}
