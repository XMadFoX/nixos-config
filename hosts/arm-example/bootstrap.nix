{ modulesPath, ... }:
{
  # Small first install; the full arm-example closure is then built natively on this machine.
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "arm-example";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];

  networking.useDHCP = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXAAFexFECnZiRIWcF7gN6K0OKULr1W52lSvygYJvcB"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Defaults (8 jobs x all cores) OOM-killed nix-daemon on 16 GiB while building arm-example.
  nix.settings.max-jobs = 2;
  nix.settings.cores = 4;

  system.stateVersion = "25.05";
}
