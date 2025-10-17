source "$CONFIG_DIR/icons.sh"  # Loads all defined icons
source "$CONFIG_DIR/colors.sh" # Loads all defined colors

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set \$NAME popup.drawing=toggle"
ePOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set \$NAME popup.drawing=toggle"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
  --add item spotify.name left \
  --set spotify.name click_script="$POPUP_SCRIPT" \
  popup.horizontal=on \
  popup.align=center \
  associated_display=active \
  updates=on \
  icon.drawing=off \
  icon=":spotify:" \
  icon.font="sketchybar-app-font:Regular:16.0" \
  icon.color="$SPOTIFY_GREEN" \
  ignore_association=on \
  \
  --add item spotify.cover left \
  --set spotify.cover icon.drawing=off \
  label.drawing=off \
  background.image.scale=0.04 \
  background.color="$TRANSPARENT" \
  drawing=off \
  background.image.corner_radius=20 \
  shadow=off \
  ignore_association=on \
  \
  --add item spotify.back popup.spotify.name \
  --set spotify.back icon=􀊎 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  script="$PLUGIN_DIR/spotify.sh" \
  label.drawing=off \
  --subscribe spotify.back mouse.clicked \
  \
  --add item spotify.play popup.spotify.name \
  --set spotify.play icon=􀊔 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  updates=on \
  label.drawing=off \
  script="$PLUGIN_DIR/spotify.sh" \
  --subscribe spotify.play mouse.clicked spotify_change \
  \
  --add item spotify.next popup.spotify.name \
  --set spotify.next icon=􀊐 \
  icon.padding_left=5 \
  icon.padding_right=10 \
  label.drawing=off \
  script="$PLUGIN_DIR/spotify.sh" \
  --subscribe spotify.next mouse.clicked \
  \
  --add item spotify.shuffle popup.spotify.name \
  --set spotify.shuffle icon=􀊝 \
  icon.highlight_color=0xff1DB954 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.drawing=off \
  script="$PLUGIN_DIR/spotify.sh" \
  --subscribe spotify.shuffle mouse.clicked \
  \
  --add item spotify.repeat popup.spotify.name \
  --set spotify.repeat icon=􀊞 \
  icon.highlight_color=0xff1DB954 \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.drawing=off \
  script="$PLUGIN_DIR/spotify.sh" \
  --subscribe spotify.repeat mouse.clicked
