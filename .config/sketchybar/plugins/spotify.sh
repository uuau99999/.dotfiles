#!/usr/bin/env bash

update() {
  # STATE="$(echo "$INFO" | jq -r '.state')"
  APP="$(echo "$INFO" | jq -r '.app')"

  PLAYING=0
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=1
  fi

  IS_WHITELISTED=0
  if [ "$APP" == "Spotify" ] | [ "$APP" == "QQMusic" ] | [ "$APP" == "Music" ]; then
    IS_WHITELISTED=1
  fi

  if [ "$PLAYING" -eq 0 ] && [ "$IS_WHITELISTED" -eq 0 ]; then
    MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
    sketchybar --set "$NAME" label="$MEDIA" drawing=on \
      --set spotify.cover background.image="/tmp/cover.jpg" \
      drawing=on \
      background.color=0x00000000
  else
    sketchybar --set "$NAME" drawing=off --set spotify.cover drawing=off
  fi
}

case "$SENDER" in
"mouse.entered")
  sketchybar --set "$NAME" popup.drawing=on
  ;;
"mouse.exited.global")
  sketchybar --set "$NAME" popup.drawing=off
  ;;
*)
  update
  ;;
esac
