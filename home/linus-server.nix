# Lean home profile for headless servers (rpi5).
# fish + starship + a handful of terminal tools, visually identical to the
# desktop's terminal.nix theme. Deliberately EXCLUDES the heavy/rickety parts
# of terminal.nix: neovim-nightly/nixvim (long native aarch64 builds, pulls in
# the mkdocs/copier python stack whose test suites are timing-flaky on a Pi -
# e.g. backrefs), yazi, lazygit, zellij, jj toolchain, googleworkspace-cli.
{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    eza
    bat
    fd
    fzf
    ripgrep
    dust
    btop
    fastfetch
  ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      # Teide Color Palette
      set -l foreground E7EAEE
      set -l selection 33394a
      set -l comment 586172
      set -l red F97791
      set -l orange FFA064
      set -l yellow FFE77A
      set -l green 38FFA5
      set -l purple F7D96C
      set -l cyan 0AE7FF
      set -l pink FFB3EC

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_option $pink
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
    shellAliases = {
      # Backup/remotes reachable from the other boxes, kept for symmetry with
      # terminal.nix; the cross-host ones only ever run on the desktop.
      desktop-home = ''sshfs -o sftp_server="$(ssh linus@192.168.200.20 -p 6969 'nix eval nixpkgs#openssh --raw')/libexec/sftp-server" -p 6969 linus@192.168.200.20:/home/linus ~/Mounts/desktop'';
      neovim = ''nvim'';
    };
    shellAbbrs = {
      os-rebuild = "sudo nixos-rebuild switch --flake ~/.nixos/ &| ${pkgs.nix-output-monitor}/bin/nom";
      ls = "eza -la";
      cat = "bat";
      rm = "rm -I";
      mv = "mv -i";
      untar = "tar -xvf";
      cd = "z";
    };
  };
}
