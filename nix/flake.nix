{
  description = "hoyup's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager }:
  let
    env = import ./env.nix;
    platform = env.platform;
    user = env.user;
    pkgs = nixpkgs.legacyPackages.${platform};
    specialArgs = {
      inherit env;
    };
  in
  {
    # nix run nixpkgs#home-manager -- switch --flake .#dev --impure 
    homeConfigurations.dev = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
      ];
      extraSpecialArgs = specialArgs;
    };

    defaultPackage.${platform} = self.homeConfigurations.dev.activationPackage;
  };
}
