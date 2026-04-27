{
  config,
  pkgs,
  catppuccin,
  inputs,
  ...
}:
{
  home.username = "madfox";
  home.homeDirectory = "/home/madfox";

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

  wayland.windowManager.niri = {
    enable = true;
    package = null;
    settings = import ./niri.nix { inherit pkgs; };
  };

  wayland.windowManager.mango = {
    enable = true;
    package = pkgs.callPackage "${inputs.mango}/nix" {
      scenefx = pkgs.scenefx;
      "libxcb-wm" = pkgs.libxcb-wm;
    };
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

  imports = [
    ./hyprland.nix
  ];

  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

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
