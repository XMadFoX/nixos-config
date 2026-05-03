{
  description = "Nixos config flake";

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://vicinae.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };

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
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango.url = "github:DreamMaoMao/mango";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";

    niri-src = {
      url = "github:niri-wm/niri/v26.04";
      flake = false;
    };
    niri = {
      url = "github:sodiboo/niri-flake/very-refactor";
      inputs.niri-stable.follows = "niri-src";
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
          opencodeOverlay = import ./overlays/opencode.nix { inherit master; };
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import ./overlays/llama-cpp-turboquant.nix)
              (import ./overlays/zed-editor.nix)
              (import ./overlays/pi-coding-agent.nix)
              opencodeOverlay
            ];
          };
        in
        {
          opencode = pkgs.opencode;
          pi-coding-agent = pkgs.pi-coding-agent;
          llama-cpp-turboquant = pkgs.llama-cpp-turboquant;
          llama-cpp-turboquant-cuda = pkgs.llama-cpp-turboquant-cuda;
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
              inputs.niri.overlays.niri
              (final: prev: {
                niri-stable = prev.niri-stable.overrideAttrs {
                  postFixup = ''
                    substituteInPlace $out/lib/systemd/user/niri.service \
                      --replace-fail "ExecStart=niri" "ExecStart=$out/bin/niri"
                  '';
                };
              })
              (import ./overlays/llama-cpp-turboquant.nix)
              (import ./overlays/zed-editor.nix)
              (import ./overlays/pi-coding-agent.nix)
              (import ./overlays/openldap.nix)
              # (import ./overlays/ollama.nix)
            ];
          }

          inputs.niri.nixosModules.niri

          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          mango.nixosModules.mango
          {
            nix.settings = {
              substituters = [
                "https://niri.cachix.org"
                "https://vicinae.cachix.org"
              ];
              trusted-public-keys = [
                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
                "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
              ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.madfox = {
              imports = [
                inputs.hyprland.homeManagerModules.default
                inputs.vicinae.homeManagerModules.default
                ./userfiles/madfox.nix
                catppuccin.homeModules.catppuccin
                mango.hmModules.mango
                inputs.dms.homeModules.dank-material-shell
                inputs.noctalia.homeModules.default
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
              inputs.niri.overlays.niri
              (final: prev: {
                niri-stable = prev.niri-stable.overrideAttrs {
                  postFixup = ''
                    substituteInPlace $out/lib/systemd/user/niri.service \
                      --replace-fail "ExecStart=niri" "ExecStart=$out/bin/niri"
                  '';
                };
              })
              (import ./overlays/llama-cpp-turboquant.nix)
              (import ./overlays/zed-editor.nix)
              (import ./overlays/pi-coding-agent.nix)
              (import ./overlays/openldap.nix)
              # (import ./overlays/ollama.nix)
              (import ./overlays/opencode.nix { inherit master; })
            ];
          }

          inputs.niri.nixosModules.niri

          ./hosts/gvino/configuration.nix
          home-manager.nixosModules.home-manager
          (
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {
              # takes care of setting up portals & other system services
              programs.niri.enable = true;
              programs.niri.package = pkgs.niri-stable;

              programs.uwsm = {
                enable = true;
                waylandCompositors.niri = {
                  prettyName = "niri";
                  comment = "niri compositor managed by UWSM";
                  binPath = "/run/current-system/sw/bin/niri";
                };
              };
            }
          )
          mango.nixosModules.mango
          {
            nix.settings = {
              substituters = [
                "https://niri.cachix.org"
                "https://vicinae.cachix.org"
              ];
              trusted-public-keys = [
                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
                "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
              ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.madfox = {
              imports = [
                inputs.hyprland.homeManagerModules.default
                inputs.vicinae.homeManagerModules.default
                ./userfiles/madfox.nix
                catppuccin.homeModules.catppuccin
                mango.hmModules.mango
                inputs.dms.homeModules.dank-material-shell
                inputs.noctalia.homeModules.default
              ];
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
