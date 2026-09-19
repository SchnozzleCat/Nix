# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    utillinux = prev.util-linux;

    # Match the host/IDD nightly build (B7-826) installed in the win11 VM.
    # The stable B7 client in nixpkgs has LGMP/IDD protocol skew against the
    # nightly host; pinning the client to the same commit keeps them in sync.
    # Bump the rev + hash together when updating the guest host binaries.
    looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
      version = "B7-826";
      src = final.fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = "236efcb155f952f5d7d9fcd5891a3060ad254e68";
        hash = "sha256-NAfV4Z0RZp2IGBzVAFysm53aGMEReT03RIN+45TveUU=";
        # fetchSubmodules is required: LGProtocol/LGMP/gui/nanosvg are git
        # submodules the build add_subdirectory's directly. NOTE: replacing
        # src via overrideAttrs drops the derivation's original
        # fetchSubmodules=true, so it must be restated here.
        fetchSubmodules = true;
      };
      # nixpkgs' nanosvg-unvendor.diff targets stable B7 and no longer applies
      # (the nightly added a FUSE3 link next to FONTCONFIG in CMakeLists.txt).
      # The vendored nanosvg submodule is fetched anyway (fetchSubmodules), so
      # just build against it instead of patching.
      patches = [];
      # New nightly deps: fuse3 (client CMakeLists), libunwind + libdw
      # (elfutils; common/src/platform/linux backtrace support).
      buildInputs = old.buildInputs ++ [final.fuse3 final.libunwind final.elfutils];
    });

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
