{
    pkgs,
    lib,
    ...
}: pkgs.stdenv.mkDerivation (self: {
    pname = "sketchybar";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.58/sketchybar-app-font.ttf";
      sha256 = "sha256-VKNB5qo/gg22IwyE30Or6pctIXHYUBUvmdp6v7LgwE0=";
    };
    phases = [ "installPhase" ];

    installPhase = ''
    mkdir -p $out/Library/Fonts/
    cp $src $out/Library/Fonts/sketchybar-app-font.ttf
    '';
})
