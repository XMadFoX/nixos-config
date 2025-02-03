{ config, pkgs, catppuccin, ... }:

{
  home.username = "madfox";
  home.homeDirectory = "/home/madfox";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      alias j=z
      # nix
      alias use='nix-shell -p'
    '';
  };

  imports = [
    ./hyprland.nix
  ];

  programs = {
    zoxide.enable = true;
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  gtk = {
    enable = true;
    catppuccin.enable = true;
  };

  
  home.stateVersion = "23.11";
}
