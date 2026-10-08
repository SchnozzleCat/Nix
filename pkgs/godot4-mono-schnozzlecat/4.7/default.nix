{
  version = "4.7";
  rev = "a68f4ab4c1e3d32a6a99aa3b5128707bc24129c5";
  # fakeHash placeholder: the first build fails with "hash mismatch ... got:
  # sha256-..." -- paste the 'got' hash here (percent-encode '+' as %2B and
  # '=' as %3D). nix-update --src-only fills this on bumps.
  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  default = {
    exportTemplatesHash = "";
  };
  mono = {
    exportTemplatesHash = "";
    nugetDeps = ./deps.json;
  };
}
