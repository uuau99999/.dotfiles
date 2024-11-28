{
  pkgs,
  lib,
}:
# This cannot be built from source since Hammerspoon requires entitlements to work,
# and codesigning entitlements is unfortunately incompatible with immutability.
pkgs.stdenv.mkDerivation (self: {
  pname = "hammerspoon";
  version = "1.0.0";

  # We don't use fetchzip because that seems to unpack the .app as well.
  src = pkgs.fetchurl {
    name = "${self.pname}-${self.version}-source.zip";
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${self.version}/Hammerspoon-${self.version}.zip";
    sha256 = "sha256-XbcCtV2kfcMG6PWUjZHvhb69MV3fopQoMioK9+1+an4=";
  };

  nativeBuildInputs = [
    # Adds unpack hook.
    pkgs.unzip
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r ../Hammerspoon.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.hammerspoon.org";
    description = "Staggeringly powerful macOS desktop automation with Lua";
    license = lib.licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
})
