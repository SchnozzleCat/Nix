{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  vimUtils,
  darwin,
}: let
  version = "2024-09-08";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "bcd73a8b9a3b81242ce6c5f65e3e245eb18a4572";
    hash = "sha256-KYcAzDJ/ZExb6+sfdNbb7FDFORstjEXzfHLNQ5v6Fg4=";
  };

  meta = with lib; {
    description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
    homepage = "https://github.com/yetone/avante.nvim";
    license = licenses.asl20;
    maintainers = [];
  };

  avante-nvim-lib = rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    inherit version src meta;
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "mlua-0.10.0-beta.1" = "sha256-ZEZFATVldwj0pmlmi0s5VT0eABA15qKhgjmganrhGBY=";
      };
    };

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    buildInputs = lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security];

    buildPhase = ''
      export PKG_CONFIG_PATH=${openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH
      make BUILD_FROM_SOURCE=true
    '';

    installPhase = ''
      mkdir -p $out
      cp ./build/*.{dylib,so} $out/
    '';

    doCheck = false;
  };
in
  vimUtils.buildVimPlugin {
    pname = "avante.nvim";
    inherit version src meta;

    # The plugin expects the dynamic libraries to be under build/
    postInstall = ''
      mkdir -p $out/build
      ln -s ${avante-nvim-lib}/*.{dylib,so} $out/build
    '';
  }
