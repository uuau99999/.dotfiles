#!/usr/bin/env bash

POPUP_OFF='sketchybar --set spotify popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

spotify_prev=(
  icon=$SPOTIFY_BACK
  padding_left=10
  click_script="osascript -e 'tell application \"Spotify\" to previous track'; $POPUP_OFF;"
)

spotify_next=(
  icon=$SPOTIFY_NEXT
  padding_right=10
  click_script="osascript -e 'tell application \"Spotify\" to next track'; $POPUP_OFF;"
)

spotify_play=(
  icon=$SPOTIFY_PLAY
  click_script="osascript -e 'tell application \"Spotify\" to playpause'; "
)

spotify=(
  scroll_texts=on
  icon=󰎆
  icon.color="$GREEN"
  icon.padding_left=10
  background.color="$BAR_COLOR"
  background.height=26
  background.corner_radius="$CORNER_RADIUS"
  background.border_width=1
  background.border_color="$SHADOW_COLOR"
  background.padding_right=-5
  background.drawing=on
  label.padding_right=10
  label.max_chars=50
  associated_display=active
  updates=on
  script="$PLUGIN_DIR/spotify.sh"
  popup.height=35
  popup.horizontal=true
  popup.align=center
  ignore_association=on
)

spotify_cover=(
  script="$PLUGIN_DIR/spotify.sh"
  click_script="open -a 'Spotify';"
  label.drawing=false
  icon.drawing=false
  background.image.scale=0.04
  background.color=$TRANSPARENT
  drawing=on
  background.image.corner_radius=9
  shadow=on
  ignore_association=on
)

sketchybar --add item spotify right \
  --set spotify "${spotify[@]}" \
  --subscribe spotify media_change mouse.entered mouse.exited.global \
  --add item spotify.prev popup.spotify \
  --set spotify.prev "${spotify_prev[@]}" \
  --add item spotify.play popup.spotify \
  --set spotify.play "${spotify_play[@]}" \
  --add item spotify.next popup.spotify \
  --set spotify.next "${spotify_next[@]}" \
  --add item spotify.cover right \
  --set spotify.cover "${spotify_cover[@]}"
