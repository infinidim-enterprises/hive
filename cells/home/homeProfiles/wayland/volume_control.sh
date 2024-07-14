#!/usr/bin/env bash

DEFAULT_SINK=$(pactl info | grep "Default Sink" | awk -F'.' '{print $NF}')
default_sink=$(pactl info | grep 'Default Sink' | awk '{print $NF}')
current_volume=$(pactl list sinks | grep -A 15 "$default_sink" | grep 'Volume:' | head -n 1 | awk '{print $5}')
MUTE=$(pactl list sinks | grep -A 15 "$DEFAULT_SINK" | grep "Mute")

case "$1" in
raise)
  pactl -- set-sink-volume @DEFAULT_SINK@ +10%
  hyprctl notify 6 1000 0 "🎵⬆ ${current_volume}"
  ;;

lower)
  pactl -- set-sink-volume @DEFAULT_SINK@ -10%
  hyprctl notify 6 1000 0 "🎵⬇ ${current_volume}"
  ;;

toggle)
  pactl -- set-sink-mute @DEFAULT_SINK@ toggle
  hyprctl notify 6 1500 0 "🎵 $MUTE"
  ;;

*)
  exit 0
  ;;
esac
