#!/usr/bin/env sh
next ()
{
  osascript -e 'tell application "Spotify" to play next track'
}

back () 
{
  osascript -e 'tell application "Spotify" to play previous track'
}

play () 
{
  osascript -e 'tell application "Spotify" to playpause'
}

repeat () 
{
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else 
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle () 
{
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else 
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

update ()
{
  PLAYING=1
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name | cut -c1-40)"
    ARTIST="$(echo "$INFO" | jq -r .Artist | cut -c1-20)"
    ALBUM="$(echo "$INFO" | jq -r .Album | cut -c1-20)"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')
    LAST_COVER=$(cat /tmp/cover.id)
  fi

  args=(--animate sin 10)
  if [ $PLAYING -eq 0 ]; then
    if [[ "$COVER" != "$LAST_COVER" ]]; then
      sketchybar --set spotify.cover drawing=off
      curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
      echo "$COVER" >/tmp/cover.id
    fi
    if [ "$ARTIST" == "" ]; then
      args+=(--set spotify.name label="$ALBUM - $TRACK" drawing=on)
    else
      args+=(--set spotify.name label="$ARTIST - $TRACK" drawing=on)
    fi
    args+=(--set spotify.name icon.drawing=on \
          --set spotify.play icon=􀊆 \
           --set spotify.shuffle icon.highlight=$SHUFFLE \
           --set spotify.repeat icon.highlight=$REPEAT \
           --set spotify.cover drawing=on \
           background.image="/tmp/cover.jpg"  \
           background.color=$TRANSPARENT)
  else
    args+=(--set spotify.name icon.drawing=off\
           --set spotify.cover drawing=off \
           --set spotify.name drawing=off \
           --set spotify.name popup.drawing=off \
           --set spotify.play icon=􀊄)
  fi
  sketchybar -m "${args[@]}"
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play") play
    ;;
    "spotify.shuffle") shuffle
    ;;
    "spotify.repeat") repeat
    ;;
    *) exit
    ;;
  esac
}

mouse_hover_enter() {
  sketchybar -m --set "$NAME" popup.drawing=on
}

mouse_hover_exit() {
  sketchybar -m --set "$NAME" popup.drawing=off
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.entered") mouse_hover_enter
  ;;
  "mouse.exited.global") mouse_hover_exit
  ;;
  "forced") exit
  ;;
  *) update
  ;;
esac
