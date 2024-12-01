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
          plugin location="file://${inputs.zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/zjstatus.wasm" {
              hide_frame_for_single_pane "true"
              border_enabled  "true"
              border_char     " "
              border_position "top"

              format_center  "{tabs}"

              tab_normal               "#[fg=#A6ADC8,bg=#1E1E2E]   {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}  "
              tab_active               "#[fg=#B4BEFE,bg=#45475A,bold]   {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}  "
              tab_fullscreen_indicator ""
              tab_sync_indicator       ""
              tab_floating_indicator   "󰉈"
          }
      }
  }
''
