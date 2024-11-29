{ lib, pkgs, ... }:
{
  home.packages = [
    (import ./programs/hammerspoon.nix { inherit lib pkgs; })
  ];
  imports = [
    ./apps/yabai.nix
    # ./apps/skhd.nix
  ];
}

