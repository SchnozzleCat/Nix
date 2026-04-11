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
    pname = "zellij-pane-tracker";
    version = "unstable-2025-12-30";

    src = fetchFromGitHub {
      owner = "theslyprofessor";
      repo = "zellij-pane-tracker";
      rev = "7cbf4f9d3d98d65ba9a0a532c2bb7bc48aaf0c61";
      hash = "sha256-LSRfhkwhv/D2vvWfVzeE+B1qrTlkr2OWMDUqNSuSClY=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    postPatch = ''
      ln -sf ${./Cargo.lock} Cargo.lock
    '';

    doCheck = false;
    auditable = false;

    buildPhase = ''
      runHook preBuild
      cargo build --release --target wasm32-wasip1 --offline
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp target/wasm32-wasip1/release/zellij-pane-tracker.wasm $out/bin/
      runHook postInstall
    '';

    meta = {
      description = "Zellij plugin that exports pane names to a JSON file for shell integration";
      homepage = "https://github.com/theslyprofessor/zellij-pane-tracker";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
