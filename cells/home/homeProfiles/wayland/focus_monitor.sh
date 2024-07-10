#!/usr/bin/env bash

get_focused_monitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
}

get_monitors() {
  hyprctl monitors -j
}

find_monitor_in_direction() {
  local direction=$1
  local current_monitor_name=$2
  local target_monitor
  local current_monitor
  local current_x
  local current_y

  current_monitor=$(get_monitors | jq -r --arg name "$current_monitor_name" '.[] | select(.name == $name)')
  current_x=$(echo "$current_monitor" | jq -r '.x')
  current_y=$(echo "$current_monitor" | jq -r '.y')

  if [[ $direction == "left" ]]; then
    target_monitor=$(get_monitors | jq -r --argjson cx "$current_x" '[.[] | select(.x < $cx)] | if length == 0 then empty else sort_by(.x) | last end')
  elif [[ $direction == "right" ]]; then
    target_monitor=$(get_monitors | jq -r --argjson cx "$current_x" '[.[] | select(.x > $cx)] | if length == 0 then empty else sort_by(.x) | first end')
  elif [[ $direction == "up" ]]; then
    target_monitor=$(get_monitors | jq -r --argjson cy "$current_y" '[.[] | select(.y < $cy)] | if length == 0 then empty else sort_by(.y) | last end')
  elif [[ $direction == "down" ]]; then
    target_monitor=$(get_monitors | jq -r --argjson cy "$current_y" '[.[] | select(.y > $cy)] | if length == 0 then empty else sort_by(.y) | first end')
  fi
  echo "$target_monitor"
}

focus_monitor_workspace() {
  local target_monitor=$1
  if [[ -n $target_monitor ]]; then
    local target_workspace
    target_workspace=$(echo "$target_monitor" | jq -r '.activeWorkspace.id')
    hyprctl dispatch workspace "$target_workspace"
  else
    exit 0
  fi
}

direction=$1
if [[ -z $direction ]]; then
  echo "Usage: $0 <direction>"
  echo "Direction can be left, right, up, or down."
  exit 1
fi

current_monitor_name=$(get_focused_monitor)
target_monitor=$(find_monitor_in_direction "$direction" "$current_monitor_name")
focus_monitor_workspace "$target_monitor"
