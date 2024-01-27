remotes=("${@}")

_lock_remotes() {
  for i in "${remotes[@]}"; do
    eval "ssh admin@${i} 'sudo chvt 1'" &
  done
  wait

  echo DISPLAY was locked
}

_unlock_remotes() {
  for i in "${remotes[@]}"; do
    eval "ssh admin@${i} 'sudo chvt 7'" &
  done
  wait

  echo DISPLAY was unlocked
}

dbus-monitor --session "type='signal',interface='org.mate.ScreenSaver'" |
  while read -r x; do
    case "${x}" in
    *"boolean true"*) _lock_remotes ;;
    *"boolean false"*) _unlock_remotes ;;
    esac
  done
