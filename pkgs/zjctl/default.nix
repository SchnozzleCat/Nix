{
  lib,
  fetchFromGitHub,
  makeRustPlatform,
  rust-bin,
}: let
  toolchain = rust-bin.stable.latest.minimal.override {
    targets = ["wasm32-wasip1"];
  };
  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
in
  rustPlatform.buildRustPackage {
    pname = "zjctl";
    version = "unstable-2026-04-08";

    src = fetchFromGitHub {
      owner = "SchnozzleCat";
      repo = "zjctl";
      rev = "bf88e3f3fa643101748a8e190ae49faf4f40f454";
      hash = "sha256-UE2bjyICS4ImV0llJwCA3w+4gwzJW8dZvwK4bJGpXk0=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    postPatch = ''
      ln -sf ${./Cargo.lock} Cargo.lock
    '';

    doCheck = false;
    auditable = false;

    buildPhase = ''
      runHook preBuild
      cargo build --release --offline -p zjctl
      cargo build --release --offline -p zjctl-zrpc --target wasm32-wasip1
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -Dm755 target/release/zjctl $out/bin/zjctl
      install -Dm644 target/wasm32-wasip1/release/zrpc.wasm $out/bin/zrpc.wasm
      runHook postInstall
    '';

    meta = {
      description = "Programmatic Zellij automation CLI + plugin";
      homepage = "https://github.com/mrshu/zjctl";
      license = lib.licenses.mit;
      mainProgram = "zjctl";
      platforms = lib.platforms.unix;
    };
  }
