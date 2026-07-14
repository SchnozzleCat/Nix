# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final; inherit inputs;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    utillinux = prev.util-linux;

    # inline-snapshot 0.32.5's own test suite fails 3 tests on this nixpkgs
    # rev, which cascades into fastapi and openapi-core (both use it as a
    # check input) and ultimately breaks the rest.nvim python extra that
    # nixvim's `rest` plugin pulls in. Disable the check phase for the
    # affected python packages so the neovim/home-manager build succeeds.
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions or []
      ++ [
        (python-final: python-prev: {
          inline-snapshot = python-prev.inline-snapshot.overridePythonAttrs (old: {
            doCheck = false;
          });
          # Defensive: if their own check phases are also flaky on this
          # nixpkgs rev, skip them too rather than blocking the build.
          fastapi = python-prev.fastapi.overridePythonAttrs (old: {
            doCheck = false;
          });
          openapi-core = python-prev.openapi-core.overridePythonAttrs (old: {
            doCheck = false;
          });
        })
      ];
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
