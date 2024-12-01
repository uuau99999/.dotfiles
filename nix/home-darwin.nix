{ lib, pkgs, ... }:
{
  home.packages = [
    (import ./programs/hammerspoon.nix { inherit lib pkgs; })
  ];
  home.file = {
    ".hammerspoon".source = ../.hammerspoon;
  };
  imports = [
    ./apps/yabai.nix
    # ./apps/skhd.nix
  ];
}

