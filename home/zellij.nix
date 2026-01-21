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
  theme "teide_dark"
  themes {
    teide_dark {
        fg "#E7EAEE"
        bg "#2C313A"
        // Black should match the terminal background color
        // This ensures the top and bottom bars are transparent
        black "#191925"
        red "#F97791"
        green "#38FFA5"
        yellow "#FFE77A"
        blue "#5CCEFF"
        magenta "#FFB3EC"
        cyan "#0AE7FF"
        white "#a9b1d6"
        orange "#FFA064"
    }
  }
''
