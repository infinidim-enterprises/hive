#!/usr/bin/env bash

DEFAULT_SINK=$(pactl info | grep "Default Sink" | awk -F'.' '{print $NF}')
MUTE=$(pactl list sinks | grep -A 15 "$DEFAULT_SINK" | grep "Mute")

case "$1" in
    raise)
        pactl -- set-sink-volume @DEFAULT_SINK@ +5%
        hyprctl notify 6 1000 0 "⬆5%"
        ;;

    lower)
        pactl -- set-sink-volume @DEFAULT_SINK@ -5%
        hyprctl notify 6 1000 0 " ⬇-5%"
        ;;

    toggle)
        pactl -- set-sink-mute @DEFAULT_SINK@ toggle
        hyprctl notify 6 1500 0 " $MUTE"
        ;;

    *)
        exit 0
        ;;
esac
