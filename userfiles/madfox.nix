{
  config,
  lib,
  pkgs,
  catppuccin,
  inputs,
  ...
}:
let
  # Neovim built from the nvf flake in ~/nix/nvf (provides bin/nvim).
  nvfNeovim = inputs.mynvim.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Always reachable as `nvf`, no matter which build owns `nvim`.
  nvfAlias = pkgs.runCommandLocal "nvf-alias" { } ''
    mkdir -p $out/bin
    ln -s ${nvfNeovim}/bin/nvim $out/bin/nvf
  '';

  # Flip to true to make nvf the default `nvim`.
  # Home packages (/etc/profiles/per-user/madfox/bin) shadow the system
  # neovim, which stays reachable at /run/current-system/sw/bin/nvim.
  nvfIsDefault = false;
in
{
  home.username = "madfox";
  home.homeDirectory = "/home/madfox";
  home.packages = [ nvfAlias ] ++ lib.optional nvfIsDefault nvfNeovim;

  programs.nsticky = {
    enable = true;
    settings = {
      sticky = {
        zen-beta-pip = {
          app-id = "zen-beta";
          title = "^Picture-in-Picture$";
        };
      };
    };
  };

  # Let home Manager install and manage itself.
  #programs.home-manager.enable = true;
  #home-manager.backupFileExtension = "backup";

  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      alias j=z
      # nix
      alias use='nix-shell -p'
    '';
  };

  programs.niri.settings = import ./niri.nix { inherit lib pkgs inputs; };

  wayland.windowManager.mango = {
    enable = true;
  };

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
    plugins = { };
  };

  services.gammastep = {
    dawnTime = "23:00";
    duskTime = "07:00";
    temperature.day = 6500;
    temperature.night = 3700;
    tray = true;
  };

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };
  };

  services.handy.enable = true;

  imports = [
    inputs.umbriel.homeModules.default
    ./hyprland.nix
    ./noctalia.nix
    ./umbriel.nix
  ];

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  programs = {
    zoxide.enable = true;
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.mako.enable = true;
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-frappe-blue-standard";
      package = pkgs.catppuccin-gtk;
    };
  };
  qt.enable = true;
  qt.style.catppuccin = {
    enable = true;
    apply = true;
    accent = "blue";
    flavor = "mocha";
  };
  qt.style.name = "kvantum";
  qt.platformTheme.name = "kvantum";

  home.stateVersion = "23.11";
}
