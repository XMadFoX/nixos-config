{ config, pkgs, ... }:

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


  
  home.stateVersion = "23.11";
}
