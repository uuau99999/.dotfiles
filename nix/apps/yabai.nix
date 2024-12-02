{...}: {
  home.file = {
      ".config/yabai/yabairc".text = ''
# default layout (can be bsp, stack or float)
yabai -m config layout bsp

# New window spawns to the right if vertical split, or bottom if horizontal split
# yabai -m config window_placement second_child
#
# yabai -m config external_bar all:32:0
#
# # padding set to 12px
# yabai -m config top_padding 12
# yabai -m config bottom_padding 12
# yabai -m config left_padding 12
# yabai -m config right_padding 12
# yabai -m config window_gap 12
#
# # center mouse on window with focus
# yabai -m config mouse_follows_focus on
#
# # modifier for clicking and dragging with mouse
# yabai -m config mouse_modifier alt
# # set modifier + left-click drag to move window
# yabai -m config mouse_action1 move
# # set modifier + right-click drag to resize window
# yabai -m config mouse_action2 resize

# sudo yabai --load-sa
# yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

yabai -m config external_bar               all:40:0       \
                mouse_follows_focus        off            \
                focus_follows_mouse        off            \
                window_zoom_persist        off            \
                window_placement           second_child   \
                window_shadow              float          \
                window_opacity             on             \
                window_opacity_duration    0.2            \
                active_window_opacity      1.0            \
                normal_window_opacity      0.8            \
                window_animation_easing    ease_out_quint \
                insert_feedback_color      0xff9dd274     \
                split_ratio                0.50           \
                auto_balance               off            \
                mouse_modifier             fn             \
                mouse_action1              move           \
                mouse_action2              resize         \
                mouse_drop_action          swap           \
                                                          \
                top_padding                8              \
                bottom_padding             8              \
                left_padding               8              \
                right_padding              8              \
                window_gap                 10


# when window is dropped in center of another window, swap them (on edges it will split it)
# yabai -m mouse_drop_action swap

yabai -m rule --add app="^System Settings$" manage=off
yabai -m rule --add app="^Calculator$" manage=off
yabai -m rule --add app="^Karabiner-Elements$" manage=off
yabai -m rule --add app="^QQ音乐$" manage=off
yabai -m rule --add app="^Spotify$" manage=off
yabai -m rule --add app="^Finder$" manage=off
yabai -m rule --add app="^TencentMeeting$" manage=off
yabai -m rule --add app="^企业微信$" manage=off
yabai -m rule --add app="^Activity Monitor$" manage=off
yabai -m rule --add app="^Preview$" manage=off
yabai -m rule --add app="^QuickTime Player$" manage=off
yabai -m rule --add app="^Terminal$" manage=off

echo "yabai configuration loaded.."
      '';
    };
}
