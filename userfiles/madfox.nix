{
  config,
  lib,
  pkgs,
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
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "mauve" ];
  };
  catppuccinKde = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" ];
    accents = [ "mauve" ];
  };
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
      export PI_SKIP_VERSION_CHECK=1
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

  programs.vicinae = {
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
  catppuccin.autoEnable = true;
  catppuccin.flavor = "mocha";
  catppuccin.mako.enable = true;
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = catppuccinGtk;
    };
  };
  qt.enable = true;
  qt.style.name = "kvantum";
  qt.platformTheme.name = "kde";

  # Kvantum styles widgets, while KDE apps get their text and selection
  # colors from kdeglobals. Apply a matching palette without replacing the
  # rest of kdeglobals (which also contains application preferences).
  xdg.dataFile."color-schemes/CatppuccinMochaMauve.colors".source =
    "${catppuccinKde}/share/color-schemes/CatppuccinMochaMauve.colors";
  home.activation.catppuccinKdeColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme \
      "${config.xdg.dataHome}/color-schemes/CatppuccinMochaMauve.colors"
  '';

  home.stateVersion = "23.11";
}
