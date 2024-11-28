{ lib, pkgs, ... }:
{
  home.packages = [
    (import ./programs/hammerspoon.nix { inherit lib pkgs; })
  ];
}

