#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '$3 !~ /^ *$/ {gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<<"${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [[ "$SENDER" != "aerospace_workspace_change" ]]; then
  exit 0
fi

CURRENT_FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
if [[ $CURRENT_FOCUSED_WORKSPACE != "$FOCUSED_WORKSPACE" ]]; then
  exit 0
fi

AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
CURRENT_FOCUSED_WORKSPACE_IN_FOCUSED_MONITOR=false
for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
  if [ "$i" = "$FOCUSED_WORKSPACE" ]; then
    CURRENT_FOCUSED_WORKSPACE_IN_FOCUSED_MONITOR=true
  fi
done
if [[ ! $CURRENT_FOCUSED_WORKSPACE_IN_FOCUSED_MONITOR ]]; then
  exit 0
fi

reload_workspace_icon "$FOCUSED_WORKSPACE"
AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
sketchybar --set space.$FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR \
  label.highlight=true \
  background.border_color=$GREY

AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)
for i in $AEROSPACE_EMPTY_WORKESPACE; do
  sketchybar --set space.$i display=0
done

# 重置上一个工作区
if [[ ! -z $PREV_WORKSPACE && "$PREV_WORKSPACE" != "$FOCUSED_WORKSPACE" ]]; then
  reload_workspace_icon "$PREV_WORKSPACE"
  # prev workspace space border color
  sketchybar --set space.$PREV_WORKSPACE icon.highlight=false \
    label.highlight=false \
    background.border_color=$BACKGROUND_2
fi
