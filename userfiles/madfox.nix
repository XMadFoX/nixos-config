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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      alias j=z
      # nix
      alias use='nix-shell -p'
    '';
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
