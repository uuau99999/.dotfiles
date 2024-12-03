#!/bin/sh

sketchybar --add item weather right \
  --set weather \
  icon=󰖐 \
  icon.padding_left=20 \
  script="$PLUGIN_DIR/weather.sh" \
  update_freq=1500 \
  --subscribe weather mouse.clicked
