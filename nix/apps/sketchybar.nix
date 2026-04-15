{ lib, pkgs ,...}:
let
  sketchybarFont = import ../programs/sketchybar.nix { inherit lib pkgs; };
in
{
  home.file = {
    ".config/sketchybar".source = ../../.config/sketchybar;
  };

  # Copy sketchybar-app-font to ~/Library/Fonts so macOS can discover it
  home.activation.installSketchybarFont = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fontsDir="$HOME/Library/Fonts"
    mkdir -p "$fontsDir"
    $DRY_RUN_CMD cp -f "${sketchybarFont}/Library/Fonts/sketchybar-app-font.ttf" "$fontsDir/sketchybar-app-font.ttf"
  '';
}
