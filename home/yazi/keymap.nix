{pkgs}: ''
  [[mgr.prepend_keymap]]
  on   = "l"
  run  = "plugin smart-enter"
  desc = "Enter the child directory, or open the file"

  [[mgr.prepend_keymap]]
  on   = "L"
  run  = "plugin smart-enter detatch"
  desc = "Enter the child directory, or open the file"

  [[mgr.prepend_keymap]]
  on   = "<C-y>"
  run = ''''
  	shell '${pkgs.dragon-drop}/bin/xdragon -a -x -T "$@"'
  ''''

  [[mgr.prepend_keymap]]
  on   = [ "c", "y" ]
  run = ''''
  	shell '${pkgs.dragon-drop}/bin/xdragon -a -x -T "$@"'
  ''''

  [[mgr.prepend_keymap]]
  on   = "<C-g>"
  run = "shell 'lazygit' --confirm --block"

  [[mgr.prepend_keymap]]
  on   = "T"
  run = "tasks_show"

  [[mgr.prepend_keymap]]
  on   = "F"
  run = "plugin --sync max-preview"

  [[mgr.prepend_keymap]]
  on   = "C"
  run = "plugin chmod"

  [[mgr.prepend_keymap]]
  on   = "W"
  run = "plugin diff"

  [[mgr.prepend_keymap]]
  on   = [ "c", "a" ]
  run = "plugin compress"
  desc = "Copy to archive"

  [[mgr.prepend_keymap]]
  on   = [ "g", "r" ]
  run  = "cd ~/Repositories"
  desc = "Go to the repositories directory"

  [[mgr.prepend_keymap]]
  on   = [ "g", "n" ]
  run  = "cd ~/.nixos"
  desc = "Go to the nixos directory"


  [[mgr.prepend_keymap]]
  on   = [ "g", "l" ]
  run  = "cd ~/.local/share"
  desc = "Go to the user data directory"


  [[mgr.prepend_keymap]]
  on   = [ "g", "s" ]
  run  = "cd ~/.local/share/Steam/steamapps/common"
  desc = "Go to the steam directory"
''
