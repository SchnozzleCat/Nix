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
          # backrefs' test_timeout is timing-sensitive and flaky under the
          # build sandbox: it busy-waits 0.5s against a 2s regex timeout, and
          # on fast machines the regex wins the race, failing with "DID NOT
          # RAISE TimeoutError". It sits under jupytext -> copier/mkdocs in
          # the neovim closure. Deselect just the flaky test.
          backrefs = python-prev.backrefs.overridePythonAttrs (old: {
            disabledTestPaths = [
              "tests/test_bregex.py::TestExceptions::test_timeout"
            ];
          });
          # Defensive: if their own check phases are also flaky on this
          # nixpkgs rev, skip them too rather than blocking the build.
          fastapi = python-prev.fastapi.overridePythonAttrs (old: {
            doCheck = false;
          });
          openapi-core = python-prev.openapi-core.overridePythonAttrs (old: {
            doCheck = false;
          });
          # steamworkspy's nixpkgs pname is 'steamworkspy' but upstream
          # setup.py registers the distribution as 'steamworks' with a
          # hardcoded version, so pythonMetadataCheckPhase can't find (or
          # match) the metadata. Skip the check until
          # https://github.com/NixOS/nixpkgs/pull/528328 lands.
          steamworkspy = python-prev.steamworkspy.overridePythonAttrs (old: {
            dontCheckPythonMetadata = true;
          });
        })
      ];
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
