{ lib, pkgs ,...}: {
  home.packages = [
    (import ../programs/sketchybar.nix { inherit lib pkgs; })
  ];
  home.file = {
    ".config/sketchybar".source = ../../.config/sketchybar;
  };
}
