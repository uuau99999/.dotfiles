{ pkgs, lib, config, ... }:

let
  fontDir = ../assets/fonts;
  fontFiles = builtins.filter (name: lib.hasSuffix ".otf" name || lib.hasSuffix ".ttf" name)
    (builtins.attrNames (builtins.readDir fontDir));
  
  # Build a derivation containing all custom fonts
  customFonts = pkgs.stdenvNoCC.mkDerivation {
    pname = "custom-fonts";
    version = "1.0";
    src = fontDir;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
  };
in
{
  # Use activation script to copy fonts to ~/Library/Fonts
  home.activation.installCustomFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fontsDir="$HOME/Library/Fonts"
    mkdir -p "$fontsDir"
    
    # Copy each font file (overwrite if exists)
    for fontFile in ${lib.concatStringsSep " " fontFiles}; do
      $DRY_RUN_CMD cp -f "${customFonts}/$fontFile" "$fontsDir/$fontFile"
    done
  '';

  home.packages = with pkgs; [
    # (nerdfonts.override {
    #   fonts = [
    #     "NerdFontsSymbolsOnly"
    #   ];
    # })
  ];
}
