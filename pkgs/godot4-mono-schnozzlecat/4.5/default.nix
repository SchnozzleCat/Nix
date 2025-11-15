{lib}: rec {
  version = "4.5.1";
  rev = "76d34a272c99d516c0c4278e10b7e1892a8314e5";
  hash = "sha256-apKpoBvhhJO8H0hxDGdd10wUx+nyPR3VFEt0hnoAPmU=";
  default = {
    exportTemplatesHash = "";
  };
  mono = {
    exportTemplatesHash = "";
    nugetDeps = ./deps.json;
  };
}
