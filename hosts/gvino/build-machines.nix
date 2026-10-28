{
  nix.buildMachines = [
    {
      hostName = "tsiteli.hs.local";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = "madfox";
      sshKey = "/home/madfox/.ssh/id_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUo0T09GYVlLV25xOHBuaFRNbjFFeEtkK1VYMWkrV0VWTTBGWkpGWUVMWVoK";
      maxJobs = 3;
      speedFactor = 2;
      supportedFeatures = [
        "big-parallel"
      ];
    }
    {
      hostName = "rpi5-2";
      system = "aarch64-linux";
      protocol = "ssh-ng";
      sshUser = "root";
      sshKey = "/home/madfox/.ssh/id_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUwwWjMxd3dOUEdNZFI1UjJza0pkdzdQa1A3KzNsSHFzUWtBUTAySm03Smggcm9vdEBuaXhvcy1pbnN0YWxsZXIK";
      maxJobs = 1;
      speedFactor = 2;
      supportedFeatures = [
        "big-parallel"
      ];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
