{pkgs}: ''
  [[manager.prepend_keymap]]
  on   = "l"
  run  = "plugin smart-enter"
  desc = "Enter the child directory, or open the file"

  [[manager.prepend_keymap]]
  on   = "L"
  run  = "plugin smart-enter detatch"
  desc = "Enter the child directory, or open the file"

  [[manager.prepend_keymap]]
  on   = "<C-y>"
  run = ''''
  	shell '${pkgs.xdragon}/bin/dragon -a -x -T "$@"' --confirm
  ''''

  [[manager.prepend_keymap]]
  on   = [ "c", "y" ]
  run = ''''
  	shell '${pkgs.xdragon}/bin/dragon -a -x -T "$@"' --confirm
  ''''

  [[manager.prepend_keymap]]
  on   = "<C-g>"
  run = "shell 'lazygit' --confirm --block"

  [[manager.prepend_keymap]]
  on   = "T"
  run = "tasks_show"

  [[manager.prepend_keymap]]
  on   = "F"
  run = "plugin --sync max-preview"

  [[manager.prepend_keymap]]
  on   = "C"
  run = "plugin chmod"

  [[manager.prepend_keymap]]
  on   = "W"
  run = "plugin diff"

  [[manager.prepend_keymap]]
  on   = [ "c", "a" ]
  run = "plugin compress"
  desc = "Copy to archive"

  [[manager.prepend_keymap]]
  on   = [ "g", "r" ]
  run  = "cd ~/Repositories"
  desc = "Go to the repositories directory"

  [[manager.prepend_keymap]]
  on   = [ "g", "n" ]
  run  = "cd ~/.nixos"
  desc = "Go to the nixos directory"


  [[manager.prepend_keymap]]
  on   = [ "g", "l" ]
  run  = "cd ~/.local/share"
  desc = "Go to the user data directory"


  [[manager.prepend_keymap]]
  on   = [ "g", "s" ]
  run  = "cd ~/.local/share/Steam/steamapps/common"
  desc = "Go to the steam directory"
''
