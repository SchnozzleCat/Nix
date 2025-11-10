{pkgs}: ''
  if [[ -z "$(pgrep -l wf-recorder)" ]]; then
    file=~/Videos/$(date +'%Y-%m-%d-%H%M%S_grim_annotated.mp4')
    ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -f "$file"; ${pkgs.dragon-drop}/bin/xdragon -a -x "$file"
    else
  pkill -SIGINT wf-recorder
    fi
''
