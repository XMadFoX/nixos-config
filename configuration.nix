# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./baseconf.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.secrets = {
      "/crypto_keyfile.bin" = "/crypto_keyfile.bin";
    };
    initrd.luks.devices = {
      "luks-64832d03-aefb-4f5a-8122-bf75ecffa902" = {
        device = "/dev/disk/by-uuid/64832d03-aefb-4f5a-8122-bf75ecffa902";
      };
      "luks-home" = {
        device = "/dev/disk/by-uuid/62b224ba-406b-4d34-b7bb-a49607a647a8";
        keyFile = "/crypto_keyfile.bin";
      };
    };

    supportedFilesystems = ["bcachefs"];

    # register appimage-run to run appimages
    binfmt.registrations.appimage = {
  wrapInterpreterInShell = false;
  interpreter = "${pkgs.appimage-run}/bin/appimage-run";
  recognitionType = "magic";
  offset = 0;
  mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
  magicOrExtension = ''\x7fELF....AI\x02'';
};
  };

  fileSystems."/home" = {
    device = "/dev/mapper/luks-home";
    fsType = "bcachefs";
    options = [ "defaults" ];  # You can specify more mount options if needed
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "UTC";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.madfox = {
    isNormalUser = true;
    description = "madfox";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

    programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  glibc
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];

  services.flatpak.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];
  hardware.opengl.driSupport32Bit = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
