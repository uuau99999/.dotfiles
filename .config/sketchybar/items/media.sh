source "$CONFIG_DIR/icons.sh"  # Loads all defined icons
source "$CONFIG_DIR/colors.sh" # Loads all defined colors

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
  --add item media.name left \
  --set media.name script="$PLUGIN_DIR/media.sh" \
  popup.horizontal=on \
  popup.align=center \
  associated_display=active \
  updates=on \
  update_freq=3 \
  icon.drawing=off \
  icon=":spotify:" \
  icon.font="sketchybar-app-font:Regular:16.0" \
  icon.color="$MEDIA_ACCENT" \
  ignore_association=on \
  --subscribe media.name mouse.entered mouse.exited.global \
  \
  --add item media.cover left \
  --set media.cover icon.drawing=off \
  label.drawing=off \
  background.image.scale=0.04 \
  background.color="$TRANSPARENT" \
  drawing=off \
  background.image.corner_radius=20 \
  shadow=off \
  ignore_association=on \
  \
  --add item media.back popup.media.name \
  --set media.back icon=$MEDIA_BACK \
  icon.padding_left=5 \
  icon.padding_right=5 \
  script="$PLUGIN_DIR/media.sh" \
  label.drawing=off \
  --subscribe media.back mouse.clicked \
  \
  --add item media.play popup.media.name \
  --set media.play icon=$MEDIA_PLAY \
  icon.padding_left=5 \
  icon.padding_right=5 \
  updates=on \
  label.drawing=off \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media.play mouse.clicked spotify_change \
  \
  --add item media.next popup.media.name \
  --set media.next icon=$MEDIA_NEXT \
  icon.padding_left=5 \
  icon.padding_right=10 \
  label.drawing=off \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media.next mouse.clicked \
  \
  --add item media.shuffle popup.media.name \
  --set media.shuffle icon=$MEDIA_SHUFFLE \
  icon.highlight_color=0xff1DB954 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.drawing=off \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media.shuffle mouse.clicked \
  \
  --add item media.repeat popup.media.name \
  --set media.repeat icon=$MEDIA_REPEAT \
  icon.highlight_color=0xff1DB954 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.drawing=off \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media.repeat mouse.clicked
