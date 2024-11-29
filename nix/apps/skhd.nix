{...}: {
  home.file = {
    ".config/skhd/skhdrc".text = ''
#change focus between external displays (left and right)
ctrl + alt - h: yabai -m display --focus west
ctrl + alt - l: yabai -m display --focus east
# move window to space #
alt - 1 : yabai -m window --space 1;
alt - 2 : yabai -m window --space 2;
alt - 3 : yabai -m window --space 3;
alt - 4 : yabai -m window --space 4;
alt - 5 : yabai -m window --space 5;
alt - 6 : yabai -m window --space 6;
alt - 7 : yabai -m window --space 7;
# stop/start/restart yabai
ctrl + alt - q : yabai --stop-service
ctrl + alt - s : yabai --start-service
ctrl + alt - r : yabai --restart-service
      '';
  };
}
