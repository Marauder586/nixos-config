{
  description = "Modular NixOS / home-manager configuration";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    helix.url            = "github:helix-editor/helix/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url     = "github:danth/stylix/release-25.11";
    nix-colors.url = "github:misterio77/nix-colors";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system   = "x86_64-linux";
    features = import ./features.nix;
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    # Args forwarded to every NixOS module and home-manager module
    sharedArgs = { inherit inputs features pkgs-unstable; };
  in {
    # ── NixOS systems ──────────────────────────────────────────
    nixosConfigurations.mochi = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = sharedArgs;
      modules = [
        ./hosts/mochi
        inputs.stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.extraSpecialArgs = sharedArgs;
          home-manager.users.marauder   = import ./home.nix;
        }
      ];
    };
  };
}
