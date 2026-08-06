{
  description = "hoyup's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-nvim.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Magit-inspired TUI git client — https://github.com/altsem/gitu
    gitu.url = "github:altsem/gitu";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-nvim, home-manager, nix-darwin, gitu, ... }:
  let
    env = import ./env.nix;
    platform = env.platform;
    user = env.user;
    pkgs = nixpkgs.legacyPackages.${platform};
    nvimPkgs = nixpkgs-nvim.legacyPackages.${platform};
    # Flake package for home-manager (see docs/installing.md "Using Nix flakes")
    gituPackage = gitu.packages.${platform}.default;
    specialArgs = {
      inherit env nvimPkgs gituPackage;
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

    darwinConfigurations.dev = nix-darwin.lib.darwinSystem {
      system = platform;
      specialArgs = specialArgs;
      modules = [
        ./darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} = {
              imports = [
                ./home.nix
                ./home-darwin.nix
              ];
            };
          }
      ];
    };

    # optional
    defaultPackage.${platform} = self.homeConfigurations.dev.activationPackage;
  };
}
