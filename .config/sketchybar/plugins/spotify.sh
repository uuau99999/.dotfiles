#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh" # Loads all defined icons

update() {
  STATE="$(echo "$INFO" | jq -r '.state')"
  APP="$(echo "$INFO" | jq -r '.app')"

  PLAYING=0
  if [[ "$(echo "$INFO" | jq -r '.["Player State"]')" -eq "Playing" ]]; then
    PLAYING=1
  fi

  IS_WHITELISTED=0
  if [ "$APP" = "Spotify" ] || [ "$APP" = "QQ音乐" ] || [ "$APP" = "Music" ]; then
    IS_WHITELISTED=1
  fi
  if [ "$STATE" = "playing" ]; then
    sketchybar --set spotify.play icon=$SPOTIFY_PALUSE
  else
    sketchybar --set spotify.play icon=$SPOTIFY_PLAY
  fi
  MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
  COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
  if [ ! -z $COVER ]; then
    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
  fi

  if
    [[ $PLAYING -eq 1 && $IS_WHITELISTED -eq 1 && ! -z $MEDIA ]]
  then
    sketchybar --set "$NAME" label="$MEDIA" drawing=on
    # sketchybar --set spotify.cover drawing=off
    if [[ ! -z $COVER && "$APP" = "Spotify" ]]; then
      # curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
      sketchybar --set spotify.cover background.image="/tmp/cover.jpg" \
        drawing=on \
        background.color=0x00000000
    else
      sketchybar --set spotify.cover drawing=off
    fi
  else
    sketchybar --set "$NAME" drawing=off --set spotify.cover drawing=off
  fi
}

case "$SENDER" in
"mouse.entered")
  if [[ $APP = "Spotify" ]]; then
    sketchybar --set "$NAME" popup.drawing=on
  fi
  ;;
"mouse.exited.global")
  sketchybar --set "$NAME" popup.drawing=off
  ;;
*)
  update
  ;;
esac
