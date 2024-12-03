{ lib, pkgs, ... }:
{
  home.packages = [
    (import ./programs/hammerspoon.nix { inherit lib pkgs; })
  ];
  home.file = {
    ".hammerspoon".source = ../.hammerspoon;
    ".config/sketchybar".source = ../.config/sketchybar;
  };
  imports = [
    ./apps/yabai.nix
    ./apps/aerospace.nix
    # ./apps/skhd.nix
  ];
}

