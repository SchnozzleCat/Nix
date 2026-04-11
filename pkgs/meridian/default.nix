{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  nodejs,
  cacert,
  makeWrapper,
}: let
  src = fetchFromGitHub {
    owner = "rynfar";
    repo = "meridian";
    rev = "d8e3fe6c2f86bb6a04d3c531bf5bd39e3d366e4d";
    hash = "sha256-Ciu63nbt/HbWA3IHff5pyfm2ijUsfqKNDi7oJzpTR9w=";
  };

  # Fixed-output derivation that fetches deps via bun and runs the upstream
  # build. Bump outputHash on version bumps. Must not reference store paths,
  # so no shebang patching or wrapping happens here.
  built = stdenvNoCC.mkDerivation {
    pname = "meridian-build";
    version = "1.30.1";
    inherit src;

    nativeBuildInputs = [bun nodejs cacert];

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-56DTp4sKW2G6vWn5T8Tpy0oRCBDCgufKLoJeC5TNNHI=";

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      bun install --frozen-lockfile
      rm -rf dist
      bun build bin/cli.ts src/proxy/server.ts \
        --outdir dist --target node --splitting \
        --external @anthropic-ai/claude-agent-sdk \
        --entry-naming '[name].js'
      node node_modules/typescript/bin/tsc -p tsconfig.build.json
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist node_modules package.json $out/
      [ -d plugin ] && cp -r plugin $out/ || true
      [ -d assets ] && cp -r assets $out/ || true
      runHook postInstall
    '';
  };
in
  stdenv.mkDerivation {
    pname = "meridian";
    version = "1.30.1";

    dontUnpack = true;
    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/meridian $out/bin
      cp -r ${built}/. $out/lib/meridian/
      makeWrapper ${nodejs}/bin/node $out/bin/meridian \
        --add-flags $out/lib/meridian/dist/cli.js
      ln -s meridian $out/bin/claude-max-proxy
      runHook postInstall
    '';

    meta = {
      description = "Local Anthropic API powered by your Claude Max subscription";
      homepage = "https://github.com/rynfar/meridian";
      license = lib.licenses.mit;
      mainProgram = "meridian";
      platforms = lib.platforms.unix;
    };
  }
