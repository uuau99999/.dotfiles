{
    pkgs,
    lib,
    ...
}: pkgs.stdenv.mkDerivation (self: {
    pname = "sketchybar";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf";
      sha256 = "sha256-5J7jKBrKZ2NMLnwCYdiYImFJZk6YQrf+Ya+MRybR8d4=";
    };
    phases = [ "installPhase" ];

    installPhase = ''
    mkdir -p $out/Library/Fonts/
    cp $src $out/Library/Fonts/
    '';
})
