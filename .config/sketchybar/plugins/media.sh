#!/usr/bin/env sh
source "$CONFIG_DIR/colors.sh" # Loads all defined colors


# ===== Player Detection & Control Abstraction =====

get_active_player() {
  local bundle
  bundle=$(nowplaying-cli get appBundleIdentifier 2>/dev/null | head -1)
  # Fallback: some players (e.g. Chrome extensions) only expose ClientBundleIdentifier
  if [ -z "$bundle" ] || [ "$bundle" = "null" ]; then
    bundle=$(nowplaying-cli get-raw 2>/dev/null \
      | grep -o '"kMRMediaRemoteNowPlayingInfoClientBundleIdentifier" *: *"[^"]*"' \
      | sed 's/.*: *"//;s/"//')
  fi
  # Normalize: extract base bundle ID (strip extension suffixes like .app.xxxx)
  echo "$bundle" | sed 's/\.app\.[a-z0-9]*$//'
}

# Maps bundle ID to "name|icon" — icon uses sketchybar-app-font format
get_player_icon() {
  case "$1" in
    com.spotify.client)       echo ":spotify:" ;;
    com.apple.Music)          echo ":music:" ;;
    com.apple.Safari)         echo ":safari:" ;;
    com.google.Chrome*)  echo ":youtube_music:" ;;
    com.tencent.QQMusic*)     echo ":qqmusic:" ;;
    com.microsoft.edgemac)    echo ":microsoft_edge:" ;;
    com.brave.Browser*)       echo ":brave_browser:" ;;
    com.operasoftware.Opera*) echo ":opera:" ;;
    tv.plex.desktop)          echo ":plex:" ;;
    com.colliderli.iina)      echo ":iina:" ;;
    org.videolan.vlc)         echo ":vlc:" ;;
    *)                        echo "􀑪" ;;  # generic music note
  esac
}

# ===== Playback Control =====

next() {
  local player
  player=$(get_active_player)
  case "$player" in
    com.spotify.client) osascript -e 'tell application "Spotify" to play next track' ;;
    com.apple.Music)    osascript -e 'tell application "Music" to next track' ;;
    *)                  nowplaying-cli next ;;
  esac
}

back() {
  local player
  player=$(get_active_player)
  case "$player" in
    com.spotify.client) osascript -e 'tell application "Spotify" to play previous track' ;;
    com.apple.Music)    osascript -e 'tell application "Music" to previous track' ;;
    *)                  nowplaying-cli previous ;;
  esac
}

play() {
  local player
  player=$(get_active_player)
  case "$player" in
    com.spotify.client) osascript -e 'tell application "Spotify" to playpause' ;;
    com.apple.Music)    osascript -e 'tell application "Music" to playpause' ;;
    *)                  nowplaying-cli togglePlayPause ;;
  esac
}

repeat() {
  local player
  player=$(get_active_player)
  case "$player" in
    com.spotify.client)
      REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
      if [ "$REPEAT" = "false" ]; then
        sketchybar -m --set media.repeat icon.highlight=on
        osascript -e 'tell application "Spotify" to set repeating to true'
      else
        sketchybar -m --set media.repeat icon.highlight=off
        osascript -e 'tell application "Spotify" to set repeating to false'
      fi
      ;;
    com.apple.Music)
      # Apple Music: off → all → one → off
      REPEAT=$(osascript -e 'tell application "Music" to get song repeat')
      if [ "$REPEAT" = "off" ]; then
        sketchybar -m --set media.repeat icon.highlight=on
        osascript -e 'tell application "Music" to set song repeat to all'
      else
        sketchybar -m --set media.repeat icon.highlight=off
        osascript -e 'tell application "Music" to set song repeat to off'
      fi
      ;;
  esac
}

shuffle() {
  local player
  player=$(get_active_player)
  case "$player" in
    com.spotify.client)
      SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
      if [ "$SHUFFLE" = "false" ]; then
        sketchybar -m --set media.shuffle icon.highlight=on
        osascript -e 'tell application "Spotify" to set shuffling to true'
      else
        sketchybar -m --set media.shuffle icon.highlight=off
        osascript -e 'tell application "Spotify" to set shuffling to false'
      fi
      ;;
    com.apple.Music)
      SHUFFLE=$(osascript -e 'tell application "Music" to get shuffle enabled')
      if [ "$SHUFFLE" = "false" ]; then
        sketchybar -m --set media.shuffle icon.highlight=on
        osascript -e 'tell application "Music" to set shuffle enabled to true'
      else
        sketchybar -m --set media.shuffle icon.highlight=off
        osascript -e 'tell application "Music" to set shuffle enabled to false'
      fi
      ;;
  esac
}

# ===== Display Update =====

update() {
  PLAYING=1
  PLAYER=$(get_active_player)

  # Dual-channel: Spotify native event (instant) vs nowplaying-cli (universal)
  if [ "$SENDER" = "spotify_change" ] && [ "$PLAYER" = "com.spotify.client" ]; then
    # Fast path: Spotify native event with $INFO JSON
    if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
      PLAYING=0
    fi
    TRACK="$(echo "$INFO" | jq -r .Name | cut -c1-40)"
    ARTIST="$(echo "$INFO" | jq -r .Artist | cut -c1-20)"
    ALBUM="$(echo "$INFO" | jq -r .Album | cut -c1-20)"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling' 2>/dev/null)
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating' 2>/dev/null)

    # Cover: download only when URL changes, use temp file for atomic swap
    COVER_URL=$(osascript -e 'tell application "Spotify" to get artwork url of current track' 2>/dev/null)
    LAST_COVER_URL=$(cat /tmp/media_cover.id 2>/dev/null)
    if [ -n "$COVER_URL" ] && [ "$COVER_URL" != "$LAST_COVER_URL" ]; then
      curl -s --max-time 10 "$COVER_URL" -o /tmp/media_cover_tmp.jpg \
        && mv /tmp/media_cover_tmp.jpg /tmp/media_cover.jpg \
        && echo "$COVER_URL" > /tmp/media_cover.id
    fi
  else
    # Universal path (timer-based polling)
    if [ "$PLAYER" = "com.spotify.client" ]; then
      # Spotify: use AppleScript for consistent text + cover data
      PSTATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
      [ "$PSTATE" = "playing" ] && PLAYING=0
      TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null | cut -c1-40)
      ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null | cut -c1-20)
      ALBUM=$(osascript -e 'tell application "Spotify" to get album of current track' 2>/dev/null | cut -c1-20)
      SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling' 2>/dev/null)
      REPEAT=$(osascript -e 'tell application "Spotify" to get repeating' 2>/dev/null)

      # Cover: same atomic URL-dedup logic as the native event path
      COVER_URL=$(osascript -e 'tell application "Spotify" to get artwork url of current track' 2>/dev/null)
      LAST_COVER_URL=$(cat /tmp/media_cover.id 2>/dev/null)
      if [ -n "$COVER_URL" ] && [ "$COVER_URL" != "$LAST_COVER_URL" ]; then
        curl -s --max-time 10 "$COVER_URL" -o /tmp/media_cover_tmp.jpg \
          && mv /tmp/media_cover_tmp.jpg /tmp/media_cover.jpg \
          && echo "$COVER_URL" > /tmp/media_cover.id
      fi
    else
      # Other players: nowplaying-cli
      RATE=$(nowplaying-cli get playbackRate 2>/dev/null)
      if [ -n "$RATE" ] && [ "$RATE" != "null" ] && [ "$RATE" != "0" ]; then
        PLAYING=0
      fi
      TRACK=$(nowplaying-cli get title 2>/dev/null | cut -c1-40)
      ARTIST=$(nowplaying-cli get artist 2>/dev/null | cut -c1-20)
      ALBUM=$(nowplaying-cli get album 2>/dev/null | cut -c1-20)

      # Artwork: base64 from nowplaying-cli, atomic write with content dedup
      ARTWORK_DATA=$(nowplaying-cli get-raw 2>/dev/null \
        | jq -r '.kMRMediaRemoteNowPlayingInfoArtworkData // empty')
      if [ -n "$ARTWORK_DATA" ]; then
        NEW_HASH=$(echo "$ARTWORK_DATA" | md5 2>/dev/null || echo "$ARTWORK_DATA" | md5sum 2>/dev/null | cut -d' ' -f1)
        OLD_HASH=$(cat /tmp/media_cover.hash 2>/dev/null)
        if [ "$NEW_HASH" != "$OLD_HASH" ]; then
          echo "$ARTWORK_DATA" | base64 -d > /tmp/media_cover_tmp.jpg 2>/dev/null \
            && mv /tmp/media_cover_tmp.jpg /tmp/media_cover.jpg \
            && echo "$NEW_HASH" > /tmp/media_cover.hash
        fi
      fi

      # Shuffle/Repeat: only Apple Music supports AppleScript among non-Spotify
      case "$PLAYER" in
        com.apple.Music)
          SHUFFLE_RAW=$(osascript -e 'tell application "Music" to get shuffle enabled' 2>/dev/null)
          REPEAT_RAW=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null)
          SHUFFLE="$SHUFFLE_RAW"
          [ "$REPEAT_RAW" = "off" ] && REPEAT="false" || REPEAT="true"
          ;;
        *)
          SHUFFLE=""
          REPEAT=""
          ;;
      esac
    fi
  fi

  # Resolve player icon and accent color
  PLAYER_ICON=$(get_player_icon "$PLAYER")
  case "$PLAYER_ICON" in
    ":youtube_music:") ICON_ACCENT=$YOUTUBE_MUSIC_RED ;;
    *)                 ICON_ACCENT=$MEDIA_ACCENT ;;
  esac

  # Determine if shuffle/repeat buttons should be visible
  SHOW_EXTRA="off"
  case "$PLAYER" in
    com.spotify.client|com.apple.Music) SHOW_EXTRA="on" ;;
  esac

  # Play/pause icon
  if [ $PLAYING -eq 0 ]; then
    PLAY_ICON="􀊆"  # pause icon (media is playing)
  else
    PLAY_ICON="􀊄"  # play icon (media is paused)
  fi

  args=(--animate sin 10)
  if [ -n "$TRACK" ] && [ "$TRACK" != "null" ]; then
    if [ -z "$ARTIST" ] || [ "$ARTIST" = "null" ]; then
      args+=(--set media.name label="$ALBUM - $TRACK" drawing=on)
    else
      args+=(--set media.name label="$ARTIST - $TRACK" drawing=on)
    fi
    args+=(--set media.name icon="$PLAYER_ICON" icon.drawing=on icon.color="$ICON_ACCENT" \
           --set media.play icon="$PLAY_ICON" \
           --set media.shuffle icon.highlight=$SHUFFLE drawing=$SHOW_EXTRA \
           --set media.repeat icon.highlight=$REPEAT drawing=$SHOW_EXTRA)

    # Cover art
    if [ -f /tmp/media_cover.jpg ] && [ -s /tmp/media_cover.jpg ]; then
      # Dynamic scale: target ~25px display height based on actual image size
      IMG_SIZE=$(sips -g pixelHeight /tmp/media_cover.jpg 2>/dev/null | tail -1 | awk '{print $2}')
      if [ -n "$IMG_SIZE" ] && [ "$IMG_SIZE" -gt 0 ] 2>/dev/null; then
        # Use awk for float division: 25 / image_height
        COVER_SCALE=$(awk "BEGIN {printf \"%.4f\", 25 / $IMG_SIZE}")
      else
        COVER_SCALE="0.04"
      fi
      args+=(--set media.cover drawing=on \
             background.image="/tmp/media_cover.jpg" \
             background.image.scale="$COVER_SCALE" \
             background.color=$TRANSPARENT)
    else
      args+=(--set media.cover drawing=off)
    fi
  else
    args+=(--set media.name icon.drawing=off \
           --set media.cover drawing=off \
           --set media.name drawing=off \
           --set media.name popup.drawing=off \
           --set media.play icon="$PLAY_ICON")
  fi
  sketchybar -m "${args[@]}"
}

# ===== Event Routing =====

mouse_clicked() {
  case "$NAME" in
    "media.next") next ;;
    "media.back") back ;;
    "media.play") play ;;
    "media.shuffle") shuffle ;;
    "media.repeat") repeat ;;
    *) exit ;;
  esac
}

mouse_hover_enter() {
  sketchybar -m --set "$NAME" popup.drawing=on
}

mouse_hover_exit() {
  sketchybar -m --set "$NAME" popup.drawing=off
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_hover_enter ;;
  "mouse.exited.global") mouse_hover_exit ;;
  "forced") exit ;;
  *) update ;;
esac
