''
  option_1=" Lock"
  option_2=" Suspend"
  option_3=" Hibernate"
  option_4=" Reboot"
  option_5=" Shutdown"
  yes=' Yes'
  no=' No'

  prompt="Uptime: $(uptime | sed 's/\([0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\1/')"

  # Pass variables to fuzzel dmenu
  run_fuzzel() {
  	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | fuzzel_cmd
  }

  fuzzel_cmd() {
  	fuzzel --dmenu \
      -p "$prompt > " \
      --lines=5
  }

  # Confirmation CMD
  confirm_cmd() {
  	fuzzel --dmenu \
  		-p 'Are you Sure? > ' \
      --lines=2
  }

  # Ask for confirmation
  confirm_exit() {
  	echo -e "$yes\n$no" | confirm_cmd
  }

  # Confirm and execute
  confirm_run () {
  	selected="$(confirm_exit)"
  	if [[ "$selected" == "$yes" ]]; then
          ''${1} && ''${2} && ''${3}
      else
          exit
      fi
  }

  run_cmd() {
  	if [[ "$1" == '--opt1' ]]; then
  		betterlockscreen -l
  	elif [[ "$1" == '--opt2' ]]; then
  		confirm_run 'systemctl suspend'
  	elif [[ "$1" == '--opt3' ]]; then
  		confirm_run 'systemctl hibernate'
  	elif [[ "$1" == '--opt4' ]]; then
  		confirm_run 'systemctl reboot'
  	elif [[ "$1" == '--opt5' ]]; then
  		confirm_run 'systemctl poweroff'
  	fi
  }

  # Actions
  chosen="$(run_fuzzel)"
  case "''${chosen}" in
      "$option_1")
  		run_cmd --opt1
          ;;
      "$option_2")
  		run_cmd --opt2
          ;;
      "$option_3") run_cmd --opt3
          ;;
      "$option_4")
  		run_cmd --opt4
          ;;
      "$option_5")
  		run_cmd --opt5
          ;;
  esac

''
