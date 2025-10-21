{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./codename.nix
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      max-jobs = "auto";
      sandbox = true;
      extra-platforms = [ "aarch64-linux" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    distributedBuilds = true;
  };

  # allow non FOSS pkgs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
    "electron-27.3.11" # for logseq
  ];

  boot = {
    # clean tmp directory on boot
    tmp.cleanOnBoot = true;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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

  services.logmein-hamachi.enable = true;

  programs.gamemode.enable = true;
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

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
    '';
  };
  programs.adb.enable = true;

  fonts.packages = with pkgs; [
    dejavu_fonts
    open-sans
    roboto-serif
    roboto-mono
    nerd-fonts.mononoki
    ipafont
    libertinus
    andika
    helvetica-neue-lt-std
    liberation-sans-narrow
    andika
    sarabun-font
    oxygenfonts
    open-sans
    work-sans
    fira
    fira-mono
    fira-code
    fira-code-nerdfont
    rictydiminished-with-firacode
    fira-go
    nerd-fonts.caskaydia-cove
    font-awesome
    tokyonight-gtk-theme
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    catppuccin-fcitx5
    catppuccin-kvantum
    catppuccin-cursors
    magnetic-catppuccin-gtk
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Source Code Pro"
        "DejaVu Sans Mono"
      ]; # TODO might not work
      sansSerif = [ "Liberation Sans" ];
      serif = [ "Liberation Serif" ];
    };
  };

  environment.sessionVariables = {
    EDITOR = "${pkgs.vim}/bin/vim";
    WLR_RENDERER_ALLOW_SOFTWARE = 1;
    NIXOS_OZONE_WL = 1;
  };

  environment.systemPackages =
    with pkgs;
    let
      waylandPkgs = [
        waybar # Highly customizable Wayland bar
        swaynotificationcenter # Notification daemon for Wayland
        libnotify # Send desktop notifications
        swww # Wallpaper daemon for Wayland
        swaybg # Background setter for Wayland
        wofi # Launcher for Wayland
        wofi-emoji
        rofi # Window switcher and launcher
        rofimoji # Emoji picker
        wlr-randr # Display configuration tool for Wayland
        wlogout # Logout menu for Wayland
        wl-clipboard
        gammastep # Screen color temperature adjuster
        ksnip # Screenshot and annotation tool
        grimblast # Screenshot tool for Wayland
        sway-contrib.grimshot # Screenshot tool
        grimblast
        hyprlock
        hyprpicker
        hyprsunset
      ];

      desktopPkgs = [
        nautilus # GNOME file manager
        feh # CLI Image viewer and wallpaper setter
        logseq # Personal knowledge management and note-taking
        kdePackages.kdeconnect-kde # Connect Android devices to desktop
        kdePackages.merkuro # Personal finance management app
        kdePackages.okular # PDF and document viewer
        kdePackages.polkit-kde-agent-1 # Authentication agent
        kdePackages.kate # Simple text editor
        kdePackages.filelight # Disk usage visualization tool
        obs-studio # Screen recording and streaming software
        corectrl # Hardware control and monitoring
        spotify
        krita # Digital painting and image editing
        inkscape # Vector graphics editor
        openrgb
        gparted
        beekeeper-studio
        crow-translate
        super-productivity
      ];

      mediaPkgs = [
        spotify # Music streaming service
        spotify-player # CLI Spotify client
        (ncspot.override {
          withCover = true;
        })
        spotube # Open-source Spotify client
        vlc
        cava
        (mpv.override {
          scripts = [
            mpvScripts.mpris
            mpvScripts.modernz
          ];
        })
        pwvucontrol
      ];

      browserPkgs = [
        firefox # Open-source web browser
        brave # Privacy-focused Chromium-based browser
        vivaldi
        inputs.zen-browser.packages."${system}".default
        ungoogled-chromium
      ];

      shellPkgs = [
        starship # Customizable shell prompt
        ripgrep # Fast text search tool
        pay-respects # Corrects previous console command. Modern "thefuck" alternative written in rust
        zoxide # Smarter cd command
        fortune # Displays random quotes
        fzf # Fuzzy finder
        bat # Modern cat with syntax highlighting
        eza # Modern ls replacement
        killall # Kills processes by name
        playerctl # Media player control
        brightnessctl # Screen brightness control
        lazygit # Terminal UI for git
        yt-dlp # YouTube video downloader
        ffmpeg-full # Complete multimedia framework
        timewarrior # Time tracking tool
        duf # Colorful Disk usage analyzer
        lm_sensors
        zoxide
        kubectl
        kubectx
        kubetui
        kubespy
        kubeconform
        gemini-cli
        opencode
        hunspellDicts.en_US
        hunspell
      ];
      virtPkgs = [
        dive
        podman-tui
        podman-compose
        fuse-overlayfs
        gnupg
        docker
        docker-credential-helpers
        nvidia-container-toolkit
        pass
      ];
      vpnPkgs = [
        cloudflare-warp # Cloudflare's VPN service
        protonvpn-gui # ProtonVPN desktop client
        haguichi
      ];
      gamePkgs = [
        lutris # Linux game platform
        bottles # Open-source game launcher
        protonup-qt # Proton compatibility tool updater
        winetricks # Windows software installation helper
        wineWowPackages.stable # Windows compatibility layer
        wineWowPackages.waylandFull # Wayland-compatible Wine
        hydralauncher
        steam-run
        gamescope
        mangohud
        vulkan-tools
        lsfg-vk
        lsfg-vk-ui
        glfw3-minecraft
      ];
      termPkgs = [
        kitty # Fast, feature-rich terminal
        wezterm # GPU-accelerated terminal
        alacritty # GPU-accelerated terminal
        wezterm
      ];
      basePkgs = [
        nano # beginner friendly editor
        btop
        nh
        nvd
        nix-output-monitor
        smartmontools # check disk state
        stow # dotfile management
        wirelesstools # iwlist (wifi scan)
        gitFull # git with send-email
        git-town
        glab
        qbittorrent
        curl # transfer data to/from a URL
        binutils # debugging binary files
        dos2unix # text file conversion
        file # file information
        htop # top replacement
        ncdu # disk size checker
        nmap # stats about clients in the network
        netcat-openbsd # swiss army knife of networking
        man-pages # system manpages (not included by default)
        mkpasswd # UNIX password creator
        lr # list recursively, ls & find replacement
        ripgrep # file content searcher, > ag > ack > grep
        rsync # file syncing tool
        strace # tracing syscalls
        tmux # detachable terminal multiplexer
        zellij
        traceroute # trace ip routes
        wget # the other URL file fetcher
        vim # slight improvement over vi
        neovim # slight improvement over vim
        helix # vi but recoded in rust
        xe # xargs with a modern interface
        nil # Nix language server
        rust-analyzer # Rust language server
        gh # github cli
        inotify-tools # file system event monitoring
        blender-hip
        surrealist
        ollama
        nixfmt-rfc-style
        syncthing # Continuous file synchronization
        pciutils # various utils for pci stuff; common for distros
        home-manager
        mesa-demos
        rocmPackages.rocm-runtime
        appimage-run
      ];
      # Distro specific rice
      zuzeRicePkgs = [
        hyfetch # superior queer fetch script
        onefetch # neofetch for git stats
        uwufetch
        fastfetch
        zsh-you-should-use
        any-nix-shell
        zsh-vi-mode
        oh-my-zsh
        oh-my-fish
      ];
      # Programming languages
      progPkgs = [
        python3 # Python 3
        lua5_4_compat # Lua 5.4
        lua54Packages.luarocks-nix # Lua package manager
        gcc
        redis # for cli only, i swear
        fuse-overlayfs
      ];
      # minimal set of gui applications
      guiPkgs = [
        gtklp # CUPS gui
        dmenu # minimal launcher
        helvum # GTK patchbay for pipewire
        easyeffects # pipewire sound tuner
        htop # system monitor
        lact # AMD GPU monitoring tool
        vscode # graphical text editor
        code-cursor
        libreoffice-fresh # fresh and spicy office tools
      ];
      # FOSS based chat apps
      minecraft = [
        prismlauncher
        badlion-client
        lunar-client
        zulu # 21
        zulu8
        zulu17
        jre17_minimal
        # graalvmPackages.graalvm-oracle_17
        temurin-jre-bin-17
      ];
      # Chat apps with proprietary components
      chatPkgs = [
        telegram-desktop # most popular instant-messenger in the IT world
        _64gram
        kotatogram-desktop
        discord # IRC-like proprietary chat service
        goofcord
        legcord
        dorion
        element-desktop
        telegram-desktop
      ];
    in
    waylandPkgs
    ++ shellPkgs
    ++ browserPkgs
    ++ termPkgs
    ++ gamePkgs
    ++ desktopPkgs
    ++ virtPkgs
    ++ vpnPkgs
    ++ basePkgs
    ++ guiPkgs
    ++ mediaPkgs
    ++ chatPkgs
    ++ progPkgs
    ++ zuzeRicePkgs
    ++ minecraft;

  programs = {
    fish.enable = true;
    zsh.enable = true;
    direnv.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  zramSwap.enable = true;
  # zramSwap.devices = [
  #   { size = 2 * 1024 * 1024; priority = 100; }
  # ];

  # neovim.override = { withNodeJs = true; };

  networking = {
    networkmanager = {
      # easiest to use; most distros use this
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

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
      };
    };

    ollama = {
      enable = true;
      acceleration = "cuda";
    };
  };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      daemon.settings = {
        data-root = "$HOME/.docker-data";
      };
    };
  };

  # use pipewire instead of pulse
  #sound.enable = true;
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    socketActivation = true;
    # systemWide = true;

    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
        "bluez5.autoswitch-profile" = false;
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

  services.tailscale.enable = true;
}
