{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  master,
  nix-colors,
  ...
}: {
  imports = [
    ./home.nix
  ];

  home = {
    username = "test";
    homeDirectory = "/home/test";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      wl-clipboard
      pavucontrol
      pyprland
      wally-cli

      # Web
      brave
      qbittorrent

      # Dev
      unityhub
      dotnet-sdk_7
      godot-4-mono
      sublime-merge
      lazygit
      jetbrains.rider
      jetbrains.datagrip
      podman-tui
      ctop
      android-studio

      (buildDotnetGlobalTool {
        pname = "dotnet-csharpier";
        version = "0.26.7";
        nugetName = "CSharpier";
        nugetSha256 = "sha256-QVfbEtkj41/b8urLx8X274KWjawyfgPTIb9HOLfduB8=";
      })
      gdtoolkit

      # Utilities
      lm_sensors
      solaar
      wtype
      ripgrep
      fzf
      git-crypt
      neovim-remote
      zip
      unzip
      flatseal

      # Terminal
      eza
      bat
      zellij
      du-dust
      neofetch
      cbonsai
      pipes
      pistol
      imv
      taskwarrior-tui
      shell_gpt

      # Files

      # Games
      steam-run
      steam-tui
      steamcmd
      (lutris.override {
        extraPkgs = pkgs: [
          wineWowPackages.stable
          winetricks
          gamescope
          mesa
        ];
      })
      runelite

      # Misc
      obsidian
      helvum
      spotify
      cinnamon.warpinator
      armcord
      jellyfin-media-player
      texlive.combined.scheme-full
      jabref
      ollama
      distrobox
      wonderdraft
      krita
    ];
  };
}
