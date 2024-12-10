{ config, pkgs, catppuccin, ... }:

{
  home.username = "madfox";
  home.homeDirectory = "/home/madfox";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
  };

  imports = [
    ./hyprland.nix
  ];

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  gtk = {
    enable = true;
    catppuccin.enable = true;
  };

  
  home.stateVersion = "23.11";
}
