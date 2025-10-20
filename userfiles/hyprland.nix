{ pkgs, lib, ... }:
{

  # programs.hyprland.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # monitor = ["eDP-1,2560x1440@96.011002,0x0,1" "DP-1,3440x1440@144,2560x0,1" "HDMI-A-1,3440x1440@72.028000,auto,1"];
      # monitor = ["eDP-1,2560x1440@96.011002,0x0,1" "DP-1,3440x1440@144,2560x0,1, vrr, 2" "HDMI-A-1,preferred,auto,1,mirror,DP-1"];
      monitor = [
        "eDP-1,2560x1440@96.011002,0x0,1.25"
        "DP-1,3440x1440@144,2560x0,1, vrr, 1"
        "HDMI-A-1,preferred,auto,1"
      ];
      # workspace= ["eDP-1,1" "HDMI-A-1,2" "DP-1,3"];
      workspace = [
        "eDP-1,1"
        "HDMI-A-1,3"
        "DP-1,2"
      ];
      source = [ "/home/madfox/hypr/mocha.conf" ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle,caps:swapescape";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
          middle_button_emulation = 1;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

      };
      device = {
        name = "asue120a:00-04f3:319b-touchpad";
        enabled = true;
      };
      # device = {
      #   name = "asus-keyboard";
      #   repeat_rate = 50;
      #     repeat_delay = 200;
      # };

      # exec-once= "bash /home/madfox/hypr-utils/start-waybar.sh";
      exec-once = "waybar";

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 4;
        gaps_out = 5;
        border_size = 4;
        # col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        # col.active_border = 0xff$pinkAlpha 0xff$peachAlpha 45deg
        "col.active_border" =
          "0xff$mauveAlpha 0xff$skyAlpha 0xff$mauveAlpha 0xff$redAlpha 0xff$mauveAlpha 0xff$skyAlpha 0xff$mauveAlpha 0xff$skyAlpha 0xff$mauveAlpha 0xff$redAlpha 315deg";
        # col.active_border = 0xff$pinkAlpha 0xff$peachAlpha 270deg
        # col.inactive_border = rgba(595959aa)
        "col.inactive_border" = "0x44$flamingoAlpha";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 5;
          passes = 2;

          vibrancy = 0.5; # 0.1696
        };

        # col.shadow = rgba(1a1a1aee)
      };

      animations = {
        enabled = true;

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 4, myBezier"
          "windowsOut, 1, 4, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 3, default"
        ];
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_status = "master";
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = true;
      };

      misc = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper = -1; # Set to 0 to disable the anime mascot wallpapers
        # variable refresh rate (stale while no updates, battery optimization)
        vfr = true;
        enable_anr_dialog = false;
      };

      windowrulev2 = [
        "suppressevent maximize, class:.*" # You'll probably like this.
        "opacity 0.9 0.8 0.9,class:^(kitty)$"
        "opacity 0.9 0.8 0.9,class:^(alacritty)$"
        "float,class:^(polkit)$"
      ];

      "$fileManager" = "dolphin";
      # "$menu" = "wofi --show drun";
      "$menu" = "rofi -show drun";
      "$mainMod" = "SUPER";
      "$terminal" = "alacritty";

      "bind" = [
        "SUPERSHIFT,RETURN,exec,$HOME/choosesession.sh"
        "CTRLSUPERSHIFT,RETURN,exec,$HOME/chooseworkspace.sh"
        "SUPER,RETURN,exec,$terminal"

        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo," # dwindle"
        # "# $mainMod, J, togglesplit, # dwindle"
        "SUPERSHIFT,Q,killactive,"
        "SUPERSHIFT,E,exec,wlogout"
        "CTRLSUPER,P,pin,"
        # "SUPERCTRLSHIFT,L,exec,$HOME/lock.sh" # L"
        "SUPERCTRLSHIFT,L,exec,hyprlock" # L"
        "SUPER,B,exec,hyprlock" # L"
        # "SUPER,D,exec,bash /home/madfox/wofi.sh" # D"
        "SUPER,D,exec,wofi --show drun" # D"
        "SUPERSHIFT,D,exec,rofi -show window"
        # "SUPER,B,exec,bash $HOME/wofi.sh emoji"
        "SUPER,E,exec,rofimoji"
        "SUPERSHIFT,N,exec,swaync-client -t -sw"
        # ""
        "SHIFT,Print,exec,grimshot copy"
        #"SHIFT,Print,exec,grimblast copy area"
        ",Print,exec,grimblast copy area"
        "SUPERSHIFT,s,exec,grimblast copy area"
        # ""
        "SUPERCTRLSHIFT,p,exec,hyprpicker -a -n"
        "SUPERSHIFT,p,exec,playerctl play-pause"
        "SUPERSHIFT,t,exec,crow"
        # ""
        # ""
        # "# Move focus with mainMod + arrow keys"
        "$mainMod, left, movefocus, l"
        "$mainMod, h, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, l, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, k, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, j, movefocus, d"
        # ""
        # "# Move window"
        "SUPERSHIFT, h, movewindow, l"
        "SUPERSHIFT, l, movewindow, r"
        "SUPERSHIFT, k, movewindow, u"
        "SUPERSHIFT, j, movewindow, d"
        # ""
        # "# Switch workspaces with mainMod + [0-9]"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # ""
        # "# Move active window to a workspace with mainMod + SHIFT + [0-9]"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # ""
        # "# Example special workspace (scratchpad)"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod CTRL, S, movetoworkspace, special:magic"
        "$mainMod, M, togglespecialworkspace, msg"
        "$mainMod SHIFT, M, movetoworkspace, special:msg"
        # ""
        # "# Scroll through existing workspaces with mainMod + scroll"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        # "# Media"
        ",XF86AudioPlay,exec,playerctl play-pause"
        # "# key 51 is \ (|?)"
        "SUPER_SHIFT,51,exec,playerctl play-pause"
        ",XF86AudioPause,exec,playerctl pause"
        ",XF86AudioStop,exec,playerctl stop"
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPrev,exec,playerctl previous"
        "WIN, F1, exec, ~/.config/hypr/gamemode.sh"
      ];
    };
  };
}
