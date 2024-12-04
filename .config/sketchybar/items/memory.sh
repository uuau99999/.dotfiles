#!/bin/bash

# 定义插件路径
MEM_SCRIPT="$PLUGIN_DIR/memory.sh"

memory=(
  icon=􀫦
  label="--%"
  script="$MEM_SCRIPT"
  click_script="open -a 'Activity Monitor';"
  update_freq=5
)

# 添加内存占用插件
sketchybar --add item mem right \
  --set mem "${memory[@]}"
