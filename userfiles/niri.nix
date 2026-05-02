{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  kdl = inputs.niri.lib.kdl;

  # niri-flake doesn't expose the new blur schema yet, so inject just this
  # small KDL fragment and keep the rest in typed Nix settings below.
  blurConfig = kdl.generator {
    inherit (pkgs) runCommand jsonkdl;
    name = "niri-blur.kdl";
    document = [
      (kdl.plain "blur" [
        (kdl.leaf "passes" 2)
        (kdl.leaf "offset" 2.0)
        (kdl.leaf "noise" 0.05)
        (kdl.leaf "saturation" 1.0)
      ])
      (kdl.plain "window-rule" [
        (kdl.leaf "match" { app-id = "^Alacritty$"; })
        (kdl.leaf "match" { app-id = "^kitty$"; })
        (kdl.leaf "match" { app-id = "^dev.zed.Zed$"; })
        (kdl.plain "background-effect" [
          (kdl.leaf "blur" true)
        ])
      ])
    ];
  };
in
{
  includes = lib.mkAfter [ (toString blurConfig) ];

  input = {
    keyboard = {
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle,caps:escape";
      };
      numlock = true;
    };

    touchpad.tap = true;
    mouse.middle-emulation = true;
    trackpoint = { };
    warp-mouse-to-focus.enable = true;
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
  };

  outputs = {
    "DP-1".mode = {
      width = 3440;
      height = 1440;
      refresh = 144.0;
    };

    "eDP-1" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 165.003006;
      };
      scale = 1.25;
    };
  };

  workspaces = {
    "00-special".name = "special";
    "01-msg".name = "msg";
    "02-w1".name = "w1";
    "03-w2".name = "w2";
    "04-w3".name = "w3";
    "05-w4".name = "w4";
    "06-w5".name = "w5";
    "07-w6".name = "w6";
    "08-w7".name = "w7";
    "09-w8".name = "w8";
    "10-w9".name = "w9";
  };

  layout = {
    gaps = 16;
    center-focused-column = "never";

    default-column-width.proportion = 0.5;
    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    focus-ring = {
      width = 4;
      active.gradient = {
        from = "#80c8ff";
        to = "#f5bde6";
        angle = 135;
      };
      inactive.color = "#505050";
    };

    shadow = {
      enable = true;
      softness = 30;
      spread = 5;
      offset = {
        x = 0;
        y = 5;
      };
      color = "#0007";
    };
  };

  spawn-at-startup = [
    { argv = [ "noctalia-shell" ]; }
    { argv = [ "waybar" ]; }
    { argv = [ "swww-daemon" ]; }
    {
      sh = "sleep 1 && swww img /home/madfox/Downloads/blahaj-wallpaper-rainbow_upscayl_4x_digital-art-4x.png";
    }
    { argv = [ "xwayland-satellite" ]; }
    { argv = [ "swaync" ]; }
    { argv = [ "easyeffects" ]; }
    { argv = [ "blueman-manager" ]; }
    { argv = [ "pwvucontrol" ]; }
  ];

  window-rules = [
    {
      matches = [
        { at-startup = true; app-id = "^com\\.github\\.wwmm\\.easyeffects$"; }
        { at-startup = true; app-id = "^\\.blueman-manager-wrapped$"; }
        { at-startup = true; app-id = "^com\\.saivert\\.pwvucontrol$"; }
      ];
      open-on-workspace = "special";
    }
    {
      geometry-corner-radius = {
        top-left = 12.0;
        top-right = 12.0;
        bottom-left = 12.0;
        bottom-right = 12.0;
      };
      clip-to-geometry = true;
    }
    {
      matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
      default-column-width = { };
    }
    {
      matches = [
        {
          app-id = "^firefox$";
          title = "^Picture-in-Picture$";
        }
      ];
      open-floating = true;
    }
    {
      matches = [
        { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
        { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
        { app-id = "^org\\.telegram\\.desktop$"; }
        { app-id = "^legcord$"; }
      ];
      block-out-from = "screen-capture";
    }
    {
      matches = [
        { app-id = "^Alacritty$"; }
        { app-id = "^kitty$"; }
      ];
      opacity = 0.8;
    }
  ];

  environment.DISPLAY = ":1";

  hotkey-overlay.skip-at-startup = true;
  prefer-no-csd = true;
  screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  animations = { };

  binds = {
    "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

    "Mod+Return" = {
      hotkey-overlay.title = "Open a Terminal: alacritty";
      action.spawn = "kitty";
    };
    "Mod+D" = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = "fuzzel";
    };
    "Super+Alt+L" = {
      hotkey-overlay.title = "Lock the Screen: swaylock";
      action.spawn = "swaylock";
    };

    "Mod+Shift+S".action.screenshot = [ ];

    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    };
    "XF86AudioNext" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl next";
    };
    "XF86AudioPrev" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl previous";
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };
    "XF86AudioStop" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl stop";
    };
    "XF86AudioPause" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl play-pause";
    };
    "XF86AudioPlay" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl play-pause";
    };
    "Mod+Shift+P" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl play-pause";
    };

    "Mod+Shift+N".action.spawn-sh = "swaync-client -t -sw";

    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
    };

    "Mod+O".action.toggle-overview = [ ];
    "Mod+Shift+Q".action.close-window = [ ];

    "Mod+Left".action.focus-column-left = [ ];
    "Mod+Down".action.focus-window-down = [ ];
    "Mod+Up".action.focus-window-up = [ ];
    "Mod+Right".action.focus-column-right = [ ];
    "Mod+H".action.focus-column-left = [ ];
    "Mod+L".action.focus-column-right = [ ];

    "Mod+Shift+Left".action.move-column-left = [ ];
    "Mod+Shift+Down".action.move-window-down = [ ];
    "Mod+Shift+Up".action.move-window-up = [ ];
    "Mod+Shift+Right".action.move-column-right = [ ];
    "Mod+Shift+H".action.move-column-left = [ ];
    "Mod+Shift+J".action.move-window-down = [ ];
    "Mod+Shift+K".action.move-window-up = [ ];
    "Mod+Shift+L".action.move-column-right = [ ];

    "Mod+J".action.focus-window-or-workspace-down = [ ];
    "Mod+K".action.focus-window-or-workspace-up = [ ];

    "Mod+Home".action.focus-column-first = [ ];
    "Mod+End".action.focus-column-last = [ ];
    "Mod+Ctrl+Home".action.move-column-to-first = [ ];
    "Mod+Ctrl+End".action.move-column-to-last = [ ];

    "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
    "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
    "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
    "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

    "Mod+Page_Down".action.focus-workspace-down = [ ];
    "Mod+Page_Up".action.focus-workspace-up = [ ];
    "Mod+U".action.focus-workspace-down = [ ];
    "Mod+I".action.focus-workspace-up = [ ];
    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
    "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

    "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
    "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
    "Mod+Shift+U".action.move-workspace-down = [ ];
    "Mod+Shift+I".action.move-workspace-up = [ ];

    "Mod+WheelScrollDown" = {
      cooldown-ms = 150;
      action.focus-workspace-down = [ ];
    };
    "Mod+WheelScrollUp" = {
      cooldown-ms = 150;
      action.focus-workspace-up = [ ];
    };
    "Mod+Ctrl+WheelScrollDown" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+WheelScrollUp" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-up = [ ];
    };

    "Mod+WheelScrollRight".action.focus-column-right = [ ];
    "Mod+WheelScrollLeft".action.focus-column-left = [ ];
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

    "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
    "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

    "Mod+1".action.focus-workspace = "w1";
    "Mod+2".action.focus-workspace = "w2";
    "Mod+3".action.focus-workspace = "w3";
    "Mod+4".action.focus-workspace = "w4";
    "Mod+5".action.focus-workspace = "w5";
    "Mod+6".action.focus-workspace = "w6";
    "Mod+7".action.focus-workspace = "w7";
    "Mod+8".action.focus-workspace = "w8";
    "Mod+9".action.focus-workspace = "w9";
    "Mod+M".action.focus-workspace = "msg";
    "Mod+S".action.focus-workspace = "special";
    "Mod+Shift+1".action.move-column-to-workspace = "w1";
    "Mod+Shift+2".action.move-column-to-workspace = "w2";
    "Mod+Shift+3".action.move-column-to-workspace = "w3";
    "Mod+Shift+4".action.move-column-to-workspace = "w4";
    "Mod+Shift+5".action.move-column-to-workspace = "w5";
    "Mod+Shift+6".action.move-column-to-workspace = "w6";
    "Mod+Shift+7".action.move-column-to-workspace = "w7";
    "Mod+Shift+8".action.move-column-to-workspace = "w8";
    "Mod+Shift+9".action.move-column-to-workspace = "w9";
    "Mod+Shift+M".action.move-column-to-workspace = "msg";
    "Mod+Ctrl+S".action.move-column-to-workspace = "special";

    "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
    "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

    "Mod+Comma".action.consume-window-into-column = [ ];
    "Mod+Period".action.expel-window-from-column = [ ];

    "Mod+R".action.switch-preset-column-width = [ ];
    "Mod+Shift+R".action.switch-preset-window-height = [ ];
    "Mod+Ctrl+R".action.reset-window-height = [ ];
    "Mod+Shift+F".action.maximize-column = [ ];
    "Mod+F".action.fullscreen-window = [ ];

    "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

    "Mod+C".action.center-column = [ ];
    "Mod+Ctrl+C".action.center-visible-columns = [ ];

    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";

    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

    "Ctrl+Print".action.screenshot-screen = [ ];
    "Alt+Print".action.screenshot-window = [ ];

    "Mod+Escape" = {
      allow-inhibiting = false;
      action.toggle-keyboard-shortcuts-inhibit = [ ];
    };

    "Mod+Shift+E".action.spawn = "wlogout";
    "Ctrl+Alt+Delete".action.quit = [ ];
  };
}
