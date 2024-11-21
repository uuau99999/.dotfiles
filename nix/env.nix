let
  # env = {
  #   user = builtins.getEnv "USER";
  #   platform = "aarch64-darwin";
  #   machine_name = builtins.getEnv "HOSTNAME";
  # };
  envContent = builtins.readFile ./nix-config.toml;
  env = builtins.fromTOML envContent;
in {
  inherit (env) user platform machine_name;
}
