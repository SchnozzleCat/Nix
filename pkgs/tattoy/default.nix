{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
  xorg,
  dbus,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "tattoy";
  version = "tattoy-v0.1.7";

  doCheck = false;

  src = fetchFromGitHub {
    owner = "tattoy-org";
    repo = "tattoy";
    rev = "${version}";
    hash = "sha256-WTfEELWi4PItKGFW3iobkFE76zWtqzwryIIxpdcHsDo=";
  };

  cargoHash = "sha256-o+Q2MIkKMnnmUQI81vy+MQelOntdtPsoS3Ln+G6Fs3Y=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    xorg.libxcb.dev
    dbus.dev
    pkg-config
  ];

  meta = with lib; {
    description = "Interactive JSON filter using jq";
    mainProgram = "jnv";
    homepage = "https://github.com/ynqa/jnv";
    license = with licenses; [mit];
    maintainers = with maintainers; [
      nealfennimore
      nshalman
    ];
  };
}
