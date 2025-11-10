{lib}: rec {
  version = "4.5.1";
  rev = "756e119906219f4b4b34778e21ef7b9a2ea12a4a";
  hash = "sha256-e6eYDGSPtNDkcW7INYZRiu+1Ah+8syfJR+6npHUeZXg=";
  default = {
    exportTemplatesHash = "";
  };
  mono = {
    exportTemplatesHash = "";
    nugetDeps = ./deps.json;
  };
}
