# wrap.nix
{pkgs}: {
  pkg,
  bin ? null, # binary name (defaults to package name)
  env ? {}, # attrset of env vars
}: let
  binName =
    if bin != null
    then bin
    else pkg.pname or pkg.name;
  envFlags = pkgs.lib.concatStringsSep " " (
    pkgs.lib.mapAttrsToList (
      name: value: ''--run 'export ${name}="${value}"' ''
    )
    env
  );
in
  pkgs.symlinkJoin {
    name = "${binName}-wrapped";
    paths = [pkg];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/${binName} ${envFlags}
    '';
  }
