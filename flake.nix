{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    master.url = "github:nixos/nixpkgs/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
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
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango.url = "github:DreamMaoMao/mango";

    niri = {
      url = "github:Naxdy/niri";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      chaotic,
      master,
      catppuccin,
      home-manager,
      lix-module,
      nur,
      nix-gaming,
      mango,
      ...
    }@inputs:
    {
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import ./overlays/opencode.nix)
            ];
          };
        in
        {
          opencode = pkgs.opencode;
        }
      );

      nixosConfigurations.tsiteli = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nur.modules.nixos.default
          chaotic.nixosModules.default
          catppuccin.nixosModules.catppuccin
          {
            nixpkgs.overlays = [
              (import ./overlays/ollama.nix)
              (import ./overlays/opencode.nix)
            ];
          }

          inputs.niri.nixosModules.default

          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          mango.nixosModules.mango
          {
            nix.settings = {
              substituters = [ "https://niri.cachix.org" ];
              trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.madfox = {
              imports = [
                ./userfiles/madfox.nix
                catppuccin.homeModules.catppuccin
                mango.hmModules.mango
                inputs.niri.homeManagerModules.default
              ];
            };
            home-manager.backupFileExtension = "backup";

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
      nixosConfigurations.gvino = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nur.modules.nixos.default
          chaotic.nixosModules.default
          catppuccin.nixosModules.catppuccin
          {
            nixpkgs.overlays = [
              (import ./overlays/ollama.nix)
              (import ./overlays/opencode.nix)
            ];
          }

          inputs.niri.nixosModules.default

          ./hosts/gvino/configuration.nix
          home-manager.nixosModules.home-manager
          ({ config, lib, pkgs, ... }: {
            # takes care of setting up portals & other system services
            programs.niri.enable = true;

            programs.uwsm = {
              enable = true;
              waylandCompositors.niri = {
                prettyName = "niri";
                comment = "niri compositor (fork) managed by UWSM";
                binPath = "/run/current-system/sw/bin/niri";
              };
            };
          })
          mango.nixosModules.mango
          {
            nix.settings = {
              substituters = [ "https://niri.cachix.org" ];
              trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.madfox = {
              imports = [
                ./userfiles/madfox.nix
                catppuccin.homeModules.catppuccin
                mango.hmModules.mango
                inputs.niri.homeManagerModules.default
              ];
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
