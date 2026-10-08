# Hetzner CAX31 (aarch64, UEFI) clone of gvino.
# Appended to nixosConfigurations.gvino via extendModules; never edit gvino for this host.
{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXAAFexFECnZiRIWcF7gN6K0OKULr1W52lSvygYJvcB";
in
{
  # Drop gvino's physical hardware (btrfs/LUKS UUIDs, NVIDIA, intel microcode, x86 hostPlatform).
  disabledModules = [ ../gvino/hardware-configuration.nix ];

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = lib.mkForce "arm-example";

  # Boot: firmware may not expose writable EFI vars during nixos-anywhere kexec;
  # bootctl --no-variables still installs the EFI/BOOT/BOOTAA64.EFI fallback.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
    "sr_mod"
  ];
  boot.initrd.luks.devices = lib.mkForce { };
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  boot.binfmt.emulatedSystems = lib.mkForce [ ];
  boot.tmp.useTmpfs = false;

  # Hardware module is disabled; desktop still needs Mesa (virtio-gpu).
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = lib.mkForce false;
  hardware.nvidia.enable = lib.mkForce false;
  services.pipewire.alsa.support32Bit = lib.mkForce false;

  services.sunshine = {
    enable = lib.mkForce false;
    openFirewall = lib.mkForce false;
    package = lib.mkForce pkgs.sunshine; # drop gvino's CUDA override
  };
  # gvino defines this unit fragment unconditionally.
  systemd.user.services.sunshine.enable = false;

  # Disposable clone must not join the user's Syncthing mesh.
  services.syncthing.enable = lib.mkForce false;

  # Native builds only, sized for 8 vCPU / 16 GiB.
  nix.distributedBuilds = lib.mkForce false;
  nix.buildMachines = lib.mkForce [ ];
  nix.settings = {
    max-jobs = lib.mkForce 2;
    cores = 4;
    extra-platforms = lib.mkForce [ ];
    # Every substituter gvino merges in (baseconf, flake module, nixos default, chaotic)
    # minus the unreachable LAN cache rpi5-2.hs.local.
    substituters = lib.mkForce [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://ai.cachix.org"
      "https://noctalia.cachix.org"
      "https://cache.numtide.com"
      "https://niri.cachix.org"
      "https://vicinae.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
  };

  # Hetzner: DHCP IPv4 (/32 via 172.31.1.1), static IPv6. Single virtio NIC -> eth0.
  # The IPv6 address is per-server (from the Hetzner console); replace it on reuse.
  networking.usePredictableInterfaceNames = false;
  networking.networkmanager.unmanaged = [ "interface-name:eth0" ];
  networking.interfaces.eth0 = {
    useDHCP = true;
    ipv6.addresses = [
      {
        address = "2a01:4f8:c015:bdb0::1";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "eth0";
  };

  # Public host: firewall on, only SSH (plus inherited VPN UDP ports) reachable.
  networking.firewall.enable = lib.mkForce true;
  services.avahi.openFirewall = lib.mkForce false;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [ sshKey ];
  users.users.madfox.openssh.authorizedKeys.keys = [ sshKey ];

  # The Hetzner web console swallows Super; Alt+Shift layout toggle would also fire on Mod+Shift binds.
  home-manager.users.madfox.programs.umbriel.settings = {
    general.mod_key = lib.mkForce "Alt";
    input.keyboard.options = lib.mkForce "caps:escape";
  };
}
