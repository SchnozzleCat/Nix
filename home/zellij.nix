{
  inputs,
  pkgs,
}:
# kdl
''
  pane_frames false
  show_startup_tips false
  on_force_close "quit"
  keybinds clear-defaults=true {
    shared_except "locked" {
      bind "Ctrl Alt n" { NewPane; }
      bind "Ctrl Alt t" { NewTab; }
      bind "Ctrl Alt m" { ToggleFloatingPanes; }
      bind "Ctrl Alt j" { MoveFocus "Down"; }
      bind "Ctrl Alt k" { MoveFocus "Up"; }
      bind "Ctrl Alt h" { MoveFocus "Left"; }
      bind "Ctrl Alt l" { MoveFocus "Right"; }
      bind "Ctrl Alt J" { Resize "Increase Down"; }
      bind "Ctrl Alt K" { Resize "Increase Up"; }
      bind "Ctrl Alt H" { Resize "Increase Left"; }
      bind "Ctrl Alt L" { Resize "Increase Right"; }
      bind "Ctrl Alt f" { ToggleFocusFullscreen; }
      bind "Ctrl Alt u" { GoToPreviousTab; }
      bind "Ctrl Alt i" { GoToNextTab; }
      bind "Ctrl Alt d" { Detach; }
      bind "Ctrl Alt r" { SwitchToMode "RenameTab"; TabNameInput 0; }
      bind "Ctrl Alt y" {
        LaunchOrFocusPlugin "zellij:session-manager" {
          floating true
          move_to_focused_tab true
        }
      }
    }
    renametab {
      bind "Esc" { SwitchToMode "Normal"; }
    }
  }
  theme "catppuccin-mocha"
  themes {
    catppuccin-mocha {
      bg "#585b70"
      fg "#cdd6f4"
      red "#f38ba8"
      green "#a6e3a1"
      blue "#89b4fa"
      yellow "#f9e2af"
      magenta "#f5c2e7"
      orange "#fab387"
      cyan "#89dceb"
      black "#181825"
      white "#cdd6f4"
    }
  }
''
