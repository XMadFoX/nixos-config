{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
        url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nur.url = "github:nix-community/NUR";
    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = { self, nixpkgs, chaotic, home-manager, lix-module, nur, nix-gaming, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        nur.modules.nixos.default
        chaotic.nixosModules.default
        ./configuration.nix
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.madfox = import ./userfiles/madfox.nix;
            home-manager.backupFileExtension = "backup";

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
      ];
    };
  };
}
