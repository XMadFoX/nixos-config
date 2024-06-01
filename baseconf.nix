 {pkgs, lib, ...}: {

  imports = [
    ./codename.nix
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      max-jobs = "auto";
      sandbox = true;
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://github.com/"
        "https://user-images.githubusercontent.com/"
        "https://api.github.com/"
      ];
      substituters = [
        "https://cache.nixos.org"
      ];
    };
    distributedBuilds = true;
  };

  # allow non FOSS pkgs
  nixpkgs.config.allowUnfree = true;

  boot = {
    # clean tmp directory on boot
    tmp.cleanOnBoot = true;
  };
  
  # the kernel OOM is not good enough without swap,
  # and we dont recommend swap. This kills the most hoggy
  # processes when the system goes under a free space limit
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # <5% free
  };

  # bounded journal size
  services.journald.extraConfig = "SystemMaxUse=500M";

  programs.bash = {
    interactiveShellInit = ''
      alias use='nix-shell -p'
      alias switch-config='nixos-rebuild switch'
      alias tad='tmux attach -d'
      alias gs='git status'

      # search recursively in cwd for file glob (insensitive)
      findia () { find -iname "*''${*}*"; }
      # like findia, but first argument is directory
      findian () { path="$1"; shift; find $path -iname "*''${*}*"; }
      # like findian, but searches whole filepath
      findiap () { path="$1"; shift; find $path -ipame "*''${*}*"; }
    '';
  };

  fonts.packages = with pkgs; [
    dejavu_fonts open-sans
    roboto-serif roboto-mono
    nerdfonts ipafont
    libertinus andika
    helvetica-neue-lt-std
    liberation-sans-narrow
    andika
    sarabun-font oxygenfonts
    open-sans work-sans
    fira fira-mono fira-code
    fira-code-nerdfont
    rictydiminished-with-firacode
    fira-go
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Source Code Pro" "DejaVu Sans Mono" ]; # TODO might not work
      sansSerif = [ "Liberation Sans" ];
      serif = [ "Liberation Serif" ];
    };
  };

  environment.sessionVariables = {
    EDITOR = "${pkgs.vim}/bin/vim";
    WLR_RENDERER_ALLOW_SOFTWARE=1;
    NIXOS_OZONE_WL=1;
  };

  environment.systemPackages = with pkgs;
  let
    hyprPkgs = [
      waybar
      swaynotificationcenter
      libnotify
      swww
      wofi
      wofi-emoji
      wlr-randr
      wlogout
      gammastep
      sway-contrib.grimshot
      grimblast
    ];
    shellPkgs = [
    starship
    fnm
    thefuck
    zoxide
    fortune
    fzf
    bat # modern cat, with synax highlight
    eza
    killall
    lazygit
    ];
    # of utmost necessity for me to function
    virtPkgs = [
    dive
    podman-tui
    podman-compose
    fuse-overlayfs
    ];
    basePkgs = [
      nano              # beginner friendly editor
      btop
      nh
      nvd
      nix-output-monitor
      smartmontools     # check disk state
      stow              # dotfile management
      wirelesstools     # iwlist (wifi scan)
      gitFull           # git with send-email
      catgirl           # IRC terminal client
      curl              # transfer data to/from a URL
      binutils          # debugging binary files
      dos2unix          # text file conversion
      file              # file information
      htop              # top replacement
      ncdu              # disk size checker
      nmap              # stats about clients in the network
      netcat-openbsd    # swiss army knife of networking
      #man-pages          # system manpages (not included by default)
      mkpasswd          # UNIX password creator
      lr                # list recursively, ls & find replacement
      ripgrep           # file content searcher, > ag > ack > grep
      rsync             # file syncing tool
      strace            # tracing syscalls
      tmux              # detachable terminal multiplexer
      traceroute        # trace ip routes
      wget              # the other URL file fetcher
      vim               # slight improvement over vi
      neovim            # slight improvement over vim
      helix             # vi but recoded in rust
      xe                # xargs with a modern interface
      nil               # Nix language server
      rust-analyzer     # Rust language server
      gh                # github cli
      pci-utils         # various utils for pci stuff; common for distros
    ];
    # Distro specific rice
    zuzeRicePkgs = [
      hyfetch           # superior queer fetch script
      uwufetch
      fastfetch
      zsh-you-should-use
      any-nix-shell
      zsh-history
      zsh-vi-mode
      oh-my-zsh
      oh-my-fish
    ];
    # Programming languages
    progPkgs = [
      #pypy3
      python3              # Python 3
      lua5_4_compat              # Lua 5.4
      lua54Packages.luarocks-nix # Lua package manager
      # kotlin                     # Kotlin dev env
      # openjdk17-bootstrap        # Java 17

      redis # for cli only, i swear
    ];
    # minimal set of gui applications
    guiPkgs = [
      gtklp             # CUPS gui
      dmenu             # minimal launcher
      alacritty         # rust based terminal emulator
      kitty             # another, easy configurable terminal emulator
      helvum            # GTK patchbay for pipewire
      easyeffects       # pipewire sound tuner
      htop              # system monitor
      # vscode            # graphical text editor
      # libreoffice-fresh # fresh and spicy office tools
    ];
    # media apps
    mediaPkgs = [
      mpv        # lightweight media player
      vlc        # encoder-rich media player
      firefox    # internet explorer
      brave
      system-config-printer # printer stuff
      ollama
    ];
    # FOSS based chat apps
    libreChatPkgs = [
      # mattermost-desktop  # libre slack alternative
      # element-web         # feature-rich matrix client
      # dino                # GTK-based XMPP messenger
    ];
    vpnPkgs = [
      cloudflare-warp
    ];
    # Chat apps with proprietary components
    unfreeChatPkgs = [
      telegram-desktop # most popular instant-messenger in the IT world
      discord          # IRC-like proprietary chat service
    ];
    in hyprPkgs ++ shellPkgs ++ virtPkgs ++ vpnPkgs ++ basePkgs ++ guiPkgs ++ mediaPkgs ++ libreChatPkgs ++ unfreeChatPkgs
                ++ progPkgs ++ zuzeRicePkgs;

  programs = {
    fish.enable = true;
    zsh.enable = true;
    direnv.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # neovim.override = { withNodeJs = true; };

  networking = {
    networkmanager = { # easiest to use; most distros use this
      enable = true;
    };

    # Routers are supposed to handle firewall on local networks
    firewall.enable = false;
  };

  documentation.man.enable = true;

  services = {
    # printing setup
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        hplip
        postscript-lexmark
        splix
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
        cnijfilter2
      ];
    };
    # default touchpad support
    libinput.enable = true;
    
    openssh.enable = true;
  };

  # virtualisation.docker.enable = true;
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # use pipewire instead of pulse
  sound.enable = true;
  security = {
    rtkit.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    socketActivation = true;
    systemWide = true;

    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };

  };
  hardware.pulseaudio.enable = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  services.blueman.enable = true;
}
