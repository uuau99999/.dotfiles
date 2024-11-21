let
  envContent = builtins.readFile ./nix-config.toml;
  env = builtins.fromTOML envContent;
in {
  inherit (env) user home platform;
}
