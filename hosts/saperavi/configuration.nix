# Lenovo Legion 5 15IAX10: Core Ultra 7 255HX (Arrow Lake), RTX 5070 Laptop, MT7925 Wi-Fi.
# Dual boot with Windows 11 on the same NVMe; ESP (1 GiB) shared and mounted at /boot.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../baseconf.nix
    ../../services.nix
    inputs.hyprland.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    loader.efi.canTouchEfiVariables = true;
    # Signed systemd-boot + UKIs for Secure Boot (Valorant/Vanguard on the Windows side needs it on).
    # Keys: `sudo sbctl create-keys` before first switch; enroll with `sbctl enroll-keys --microsoft --firmware-builtin`.
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 10;
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;
  };

  # 8 GiB fallback on top of zram (baseconf); no hibernation.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  networking.hostName = "saperavi";
  networking.networkmanager.enable = true;

  # baseconf disables the firewall for home LANs; a laptop joins untrusted networks.
  networking.firewall = {
    enable = lib.mkForce true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  time.timeZone = "Asia/Tbilisi";
  i18n.defaultLocale = "en_US.UTF-8";

  # NVIDIA: Blackwell needs the open kernel module; PRIME offload keeps the dGPU off until requested.
  hardware.nvidia.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # `nvidia-offload <cmd>`
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    config = {
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  services.desktopManager.plasma6.enable = true;
  # Same kded6 workaround as gvino (gtkconfig rewrites GTK colors, bluedevil fights blueman).
  environment.etc."xdg/kded5rc".text = ''
    [Module-gtkconfig]
    autoload=false

    [Module-bluedevil]
    autoload=false
  '';
  services.displayManager = {
    sddm.enable = false;
    gdm.enable = false;
    ly.enable = true;
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.syncthing.enable = true;

  users.users.madfox = {
    isNormalUser = true;
    description = "Kate";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "docker"
      "adbusers"
      "kvm"
      "video"
      "render"
      "input"
      "uinput"
      "ydotool"
    ];
    packages = with pkgs; [ kdePackages.kate ];
  };

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
    nh
    sbctl
  ];

  system.stateVersion = "26.11";
}
