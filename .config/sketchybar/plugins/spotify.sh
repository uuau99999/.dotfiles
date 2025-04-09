#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"  # Loads all defined icons
source "$CONFIG_DIR/colors.sh" # Loads all defined colors

update() {
  STATE="$(echo "$INFO" | jq -r '.state')"
  APP="$(echo "$INFO" | jq -r '.app')"

  echo "$APP" >/tmp/sketchybar_spotify_app

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

  if
    [[ $PLAYING -eq 1 && $IS_WHITELISTED -eq 1 && ! -z $MEDIA ]]
  then
    if [[ "$STATE" != "playing" ]]; then
      sketchybar --set spotify.cover background.image.rotate_rate=0.0
      exit 0
    fi
    icon_strip="$($CONFIG_DIR/plugins/icon_map.sh "$APP")"
    if [ "$icon_strip" = ":default:" ]; then
      icon_strip=":music:"
    fi
    sketchybar --animate sin 10 --set "$NAME" label="$MEDIA" drawing=on icon="$icon_strip"
    if [[ "$APP" = "Spotify" ]]; then
      COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
      LAST_COVER=$(cat /tmp/cover.id)
      if [ "$COVER" != "$LAST_COVER" ]; then
        sketchybar --set spotify.cover drawing=off background.image.rotate_rate=0.0
        curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
        echo "$COVER" >/tmp/cover.id
      fi
      sketchybar --set "$NAME" icon.color="$SPOTIFY_GREEN"
      sketchybar --set spotify.cover background.image="/tmp/cover.jpg" \
        background.color=0x00000000
      sketchybar --set spotify.cover background.image.rotate_rate=45.0
      # sketchybar --set spotify.cover background.image.rotate_degrees=45.0
      sketchybar --set spotify.cover drawing=on
    fi
    if [[ -z $COVER || "$APP" != "Spotify" ]]; then
      sketchybar --set "$NAME" icon.color="$GREEN"
      sketchybar --set spotify.cover drawing=off
    fi
  else
    sketchybar --set "$NAME" drawing=off --set spotify.cover drawing=off background.image.rotate_rate=0.0
  fi
}

case "$SENDER" in
"mouse.entered")
  SKETCHYBAR_APP=$(cat /tmp/sketchybar_spotify_app)
  if [[ $SKETCHYBAR_APP = "Spotify" ]]; then
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
