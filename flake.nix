{
  description = "Modular NixOS / home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    helix.url = "github:helix-editor/helix/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-25.11";
    nix-colors.url = "github:misterio77/nix-colors";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Build specialArgs/extraSpecialArgs for a given host features file
    mkArgs = featuresFile: { inherit inputs pkgs-unstable; features = import featuresFile; };

    # Build a NixOS system with stylix + home-manager wired in
    mkNixosSystem = { hostDir, featuresFile }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = mkArgs featuresFile;
      modules = [
        hostDir
        inputs.stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.extraSpecialArgs = mkArgs featuresFile;
          home-manager.users.marauder   = import ./home.nix;
        }
      ];
    };
  in {
    # ── NixOS systems ──────────────────────────────────────────
    nixosConfigurations.mochi = mkNixosSystem {
      hostDir      = ./hosts/mochi;
      featuresFile = ./hosts/mochi/features.nix;
    };

    nixosConfigurations.mochi-guest = mkNixosSystem {
      hostDir      = ./hosts/mochi-guest;
      featuresFile = ./hosts/mochi-guest/features.nix;
    };

    # ── Non-NixOS homes (home-manager standalone) ──────────────
    # Rebuild: home-manager switch --flake .#marauder@wsl-nix
    homeConfigurations."marauder@wsl-nix" = home-manager.lib.homeManagerConfiguration {
      pkgs            = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = mkArgs ./hosts/wsl-nix/features.nix;
      modules          = [
        inputs.stylix.homeManagerModules.stylix
        ./hosts/wsl-nix/home.nix
      ];
    };
  };
}
