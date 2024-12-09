#!/bin/bash

sid=$1

update() {
  # 처음 시작에만 작동하기 위해서
  # 현재 forced, space_change 이벤트가 동시에 발생하고 있다.
  source "$CONFIG_DIR/colors.sh"
  focused=$FOCUSED_WORKSPACE
  if [ -z "$focused" ]; then
    focused=$(aerospace list-workspaces --focused)
  fi
  SHOW=false
  COLOR=$BACKGROUND_2

  if [ "$sid" = "$focused" ]; then
    SHOW=true
    COLOR=$GREY
  fi
  sketchybar --set space.$sid icon.highlight=$SHOW \
    label.highlight=$SHOW \
    background.border_color=$COLOR
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # yabai -m space --destroy $SID
    echo ''
  else
    if [ "$MODIFIER" = "shift" ]; then
      SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Give a name to space $NAME:\" default answer \"\" with icon note buttons {\"Cancel\", \"Continue\"} default button \"Continue\"))")"
      if [ $? -eq 0 ]; then
        if [ "$SPACE_LABEL" = "" ]; then
          set_space_label "${NAME:6}"
        else
          set_space_label "${NAME:6} ($SPACE_LABEL)"
        fi
      fi
    else
      aerospace workspace ${NAME#*.}
    fi
  fi
}

case "$SENDER" in
"mouse.clicked")
  mouse_clicked
  ;;
*)
  update
  ;;
esac
