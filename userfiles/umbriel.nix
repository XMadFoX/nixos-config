{ ... }:
let
  workspaceNames = [
    "special"
    "msg"
    "w1"
    "w2"
    "w3"
    "w4"
    "w5"
    "w6"
    "w7"
    "w8"
    "w9"
  ];
in
{
  programs.umbriel = {
    enable = true;

    settings = {
      general = {
        autostart = [
          "noctalia"
          "swaync"
          "easyeffects"
          "blueman-manager"
          "pwvucontrol"
        ];
        mod_key = "Super";
        xwayland = true;
        show_cheatsheet = false;
      };

      input = {
        keyboard = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle,caps:escape";
          numlock_toggle = true;
        };
        touchpad.tap = true;
        touchpad.natural_scroll = false;
        mouse.sensitivity = 0.0;
        focus.follows_mouse = true;
        cursor.follows_focus = true;
      };

      layout = {
        mode = "scrolling";
        gap = 8;
        width_presets = [
          0.33333
          0.5
          0.66667
        ];
        scrolling = {
          default_width_fraction = 0.5;
          center_underfull_strip = true;
        };
      };

      appearance = {
        prefer_no_csd = true;
        border_width = 4;
        border_focused = "#ca9ee6";
        border_unfocused = "#ca9ee655";
        corner_radius = 12;
        blur = {
          enabled = true;
          passes = 2;
          noise = 0.05;
          saturation = 1.0;
        };
        shadow = {
          enabled = true;
          softness = 30;
          offset_x = 0;
          offset_y = 5;
          color = "#00000077";
        };
      };

      # Later rules win on the same field, so terminal opacity has to come last.
      window_rule = [
        {
          match.is_focused = false;
          opacity = 0.85;
        }
        {
          match.is_focused = true;
          opacity = 1.0;
        }
        {
          match.app_id = "^(kitty|Alacritty)$";
          blur = true;
          blur_optimized = false;
          opacity = 0.9;
        }
      ];

      output = {
        "DP-1" = {
          mode = "3440x1440@144";
          vrr = "disabled";
          workspaces = workspaceNames;
        };
        "HDMI-A-1" = {
          mode = "2560x1440@59.951";
          workspaces = workspaceNames;
        };
        "eDP-1" = {
          mode = "2560x1440@165.003";
          scale = 1.25;
          workspaces = workspaceNames;
        };
      };

      keybinds = {
        "Mod+Shift+Slash" = "cheatsheet-toggle";
        "Mod+Return" = "spawn:kitty";
        "Mod+D" = "spawn:vicinae toggle";
        "Mod+W" = "spawn:handy --toggle-transcription";
        "Super+Alt+L" = "spawn:swaylock";
        "Mod+Shift+N" = "spawn:swaync-client -t -sw";
        "Mod+Shift+P" = "spawn:playerctl play-pause";
        "Mod+Ctrl+P" = "spawn:nsticky sticky toggle-active";

        "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";

        "XF86AudioRaiseVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
        "XF86AudioLowerVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        "XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioNext" = "spawn:playerctl next";
        "XF86AudioPrev" = "spawn:playerctl previous";
        "XF86AudioStop" = "spawn:playerctl stop";
        "XF86AudioPause" = "spawn:playerctl play-pause";
        "XF86AudioPlay" = "spawn:playerctl play-pause";
        "XF86MonBrightnessUp" = "spawn:brightnessctl --class=backlight set +10%";
        "XF86MonBrightnessDown" = "spawn:brightnessctl --class=backlight set 10%-";

        "Mod+O" = "overview-toggle";
        "Mod+Shift+Q" = "window-close";
        "Mod+Left" = "window-focus-left";
        "Mod+Down" = "window-focus-down";
        "Mod+Up" = "window-focus-up";
        "Mod+Right" = "window-focus-right";
        "Mod+H" = "window-focus-left";
        "Mod+L" = "window-focus-right";
        "Mod+J" = "window-focus-or-workspace-down";
        "Mod+K" = "window-focus-or-workspace-up";

        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Down" = "window-move-down";
        "Mod+Shift+Up" = "window-move-up";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+H" = "column-move-left";
        "Mod+Shift+J" = "window-move-down";
        "Mod+Shift+K" = "window-move-up";
        "Mod+Shift+L" = "column-move-right";

        "Mod+Home" = "column-focus-first";
        "Mod+End" = "column-focus-last";
        "Mod+Ctrl+Home" = "column-move-to-first";
        "Mod+Ctrl+End" = "column-move-to-last";

        "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
        "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
        "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
        "Mod+Shift+Ctrl+H" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+J" = "column-move-to-output-down";
        "Mod+Shift+Ctrl+K" = "column-move-to-output-up";
        "Mod+Shift+Ctrl+L" = "column-move-to-output-right";

        "Mod+Page_Down" = "workspace-next";
        "Mod+Page_Up" = "workspace-previous";
        "Mod+U" = "workspace-next";
        "Mod+I" = "workspace-previous";
        "Mod+Ctrl+Page_Down" = "column-move-to-workspace-next";
        "Mod+Ctrl+Page_Up" = "column-move-to-workspace-previous";
        "Mod+Ctrl+U" = "column-move-to-workspace-next";
        "Mod+Ctrl+I" = "column-move-to-workspace-previous";
        "Mod+Shift+Page_Down" = "workspace-move-down";
        "Mod+Shift+Page_Up" = "workspace-move-up";
        "Mod+Shift+U" = "workspace-move-down";
        "Mod+Shift+I" = "workspace-move-up";

        "Mod+1" = "workspace-switch:w1";
        "Mod+2" = "workspace-switch:w2";
        "Mod+3" = "workspace-switch:w3";
        "Mod+4" = "workspace-switch:w4";
        "Mod+5" = "workspace-switch:w5";
        "Mod+6" = "workspace-switch:w6";
        "Mod+7" = "workspace-switch:w7";
        "Mod+8" = "workspace-switch:w8";
        "Mod+9" = "workspace-switch:w9";
        "Mod+M" = "workspace-switch:msg";
        "Mod+S" = "workspace-switch:special";
        "Mod+Shift+1" = "column-move-to-workspace:w1";
        "Mod+Shift+2" = "column-move-to-workspace:w2";
        "Mod+Shift+3" = "column-move-to-workspace:w3";
        "Mod+Shift+4" = "column-move-to-workspace:w4";
        "Mod+Shift+5" = "column-move-to-workspace:w5";
        "Mod+Shift+6" = "column-move-to-workspace:w6";
        "Mod+Shift+7" = "column-move-to-workspace:w7";
        "Mod+Shift+8" = "column-move-to-workspace:w8";
        "Mod+Shift+9" = "column-move-to-workspace:w9";
        "Mod+Shift+M" = "column-move-to-workspace:msg";
        "Mod+Ctrl+S" = "column-move-to-workspace:special";

        "Mod+BracketLeft" = "window-consume-or-expel-left";
        "Mod+BracketRight" = "window-consume-or-expel-right";
        "Mod+Comma" = "window-consume-left";
        "Mod+Period" = "window-consume-right";
        "Mod+R" = "window-cycle-width";
        "Mod+Shift+R" = "window-cycle-height";
        "Mod+Shift+F" = "window-toggle-maximize";
        "Mod+F" = "window-toggle-fullscreen";
        "Mod+C" = "column-center";
        "Mod+Shift+C" = "spawn:hyprpicker | wl-copy";
        "Mod+Minus" = "window-modify-width:-0.1";
        "Mod+Equal" = "window-modify-width:0.1";
        "Mod+Shift+Minus" = "window-modify-height:-0.1";
        "Mod+Shift+Equal" = "window-modify-height:0.1";
        "Mod+V" = "window-toggle-floating";
        "Mod+Shift+V" = "window-focus-switch-floating";
        "Mod+Shift+E" = "spawn:wlogout";
        "Ctrl+Alt+Delete" = "session-quit";
      };
    };
  };
}
