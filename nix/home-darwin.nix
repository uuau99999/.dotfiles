{ lib, pkgs, ... }:
{
  imports = [
    ./apps/yabai.nix
    ./apps/aerospace.nix
    ./apps/hammerspoon.nix
    ./apps/sketchybar.nix
    ./apps/fonts.nix
    # ./apps/skhd.nix
  ];
}

