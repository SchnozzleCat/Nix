{
  inputs,
  pkgs,
}:
# kdl
''
  layout {
      pane split_direction="vertical" {
          pane
      }

      pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
      }
  }
''
