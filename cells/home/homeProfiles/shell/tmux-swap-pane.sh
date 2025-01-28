current_session_id=$(tmux display-message -p "#{session_id}")
current_window_index=$(tmux display-message -p "#{window_index}")
current_pane_index=$(tmux display-message -p "#{pane_index}")
panes=$(tmux list-panes -a -F "#{session_id} #{window_index} #{pane_index} #{pane_current_command}")
menu_command='display-menu -T "#[align=centre]Select Pane to Swap"'
key_counter=0

while IFS= read -r pane; do
  session_id=$(echo "$pane" | awk '{print $1}')
  window_index=$(echo "$pane" | awk '{print $2}')
  pane_index=$(echo "$pane" | awk '{print $3}')
  pane_command=$(echo "$pane" | awk '{print $4}')

  if [ "$session_id" = "$current_session_id" ] &&
    ! { [ "$window_index" = "$current_window_index" ] &&
      [ "$pane_index" = "$current_pane_index" ]; }; then

    if [ "$key_counter" -lt 10 ]; then
      key="$key_counter"
    else
      key=""
    fi

    label="Window $window_index, Pane $pane_index: $pane_command"
    command="swap-pane -t :${window_index}.${pane_index}"
    menu_command="$menu_command \"$label\" \"$key\" \"$command\""
  fi

  key_counter=$((key_counter + 1))
done <<<"$panes"

menu_command="$menu_command \"\" \"Cancel\" \"q\" \"\""

eval "tmux $menu_command"
