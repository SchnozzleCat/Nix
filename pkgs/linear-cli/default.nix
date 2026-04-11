{
  lib,
  stdenv,
  fetchFromGitHub,
  deno,
  cacert,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "linear-cli";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FR6WuTKws75i0T00ASxr6wTHYH8MNOdboJcDYD0aYVM=";
  };

  nativeBuildInputs = [deno cacert];

  dontStrip = true;
  dontPatchELF = true;

  # Network access required to fetch deno/npm/jsr deps and run codegen.
  # Implemented as a fixed-output derivation; bump outputHash on version bumps.
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-eFTq1rU8tpfZrd3DvFZvZVq+Y9bPEfIi2tIXNRBE9s8=";

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export DENO_DIR=$TMPDIR/deno
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    deno task codegen
    deno compile \
      --allow-all \
      --no-check \
      --output linear \
      src/main.ts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 linear $out/bin/linear
    runHook postInstall
  '';

  meta = {
    description = "Linear without leaving the command line";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.mit;
    mainProgram = "linear";
    platforms = lib.platforms.unix;
  };
})
