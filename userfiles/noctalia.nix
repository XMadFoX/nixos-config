{ lib, osConfig, ... }:

let
  isLaptop = lib.elem osConfig.networking.hostName [ "tsiteli" "saperavi" ];

  # Bar widgets shown on the right/end section (v5 widget IDs).
  endWidgets = [
    "network"
    "bluetooth"
    "cpu"
    "ram"
    "tray"
    "control-center"
    "world_clock"
    "herdr"
    "wallhaven"
    "awwwall"
  ];
in
{
  # The flake module excludes the old path; Home Manager now uses a directory.
  disabledModules = [ "programs/noctalia" ];

  # v5 module namespace (was programs.noctalia-shell in v4).
  programs.noctalia = {
    enable = true;

    # settings is now a TOML attrset (snake_case keys); see
    # https://docs.noctalia.dev/v5/configuration/
    settings = lib.mkMerge [
      {
        shell = {
          # Was general.avatarImage / general.radiusRatio in v4.
          avatar_path = "/home/madfox/.face";
          corner_radius_scale = 0.8;
          # Was appLauncher.enableClipboardHistory = false in v4.
          clipboard_enabled = false;
          password_style = "random";
          settings_show_advanced = true;
          telemetry_enabled = true;
          panel = {
            clipboard_placement = "attached";
            floating_offset = 0;
          };
          screenshot = {
            annotate = true;
            confirm_region = true;
            remember_last_region = true;
            show_cursor = true;
          };
        };

        # Palette is fetched from api.noctalia.dev on first use.
        theme = {
          source = "community";
          community_palette = "Shien";
          mode = "dark";
        };

        backdrop.enabled = true;
        lockscreen.enabled = false;

        bar.main = {
          position = "top";
          margin_edge = 0;
          margin_ends = 0;
          thickness = 30;
          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "clock"
            "volume"
            "bongocat"
            "caffeine"
          ];
          end = endWidgets;
        };

        # Date/time formatting tokens (was location.monthBeforeDay in v4).
        location = {
          address = "Tbilisi, Georgia";
        };

        dock = {
          enabled = false;
          launcher_position = "none";
        };

        plugins.enabled = [
          "noctalia/wallhaven"
          "noctalia/world_clock"
          "noctalia/bongocat"
          "reaperhound/ambient-sounds"
          "0lucasmatheus/awwwall"
          "hy4ri/herdr"
        ];
        plugin_settings."hy4ri/herdr".show_other_machines = true;

        widget = {
          bongocat = {
            type = "noctalia/bongocat:cat";
            # shortcut: event number is per-machine, add a host override if a host's keyboard differs.
            input_devices = [ "/dev/input/event3" ];
            audio_spectrum = true;
            rave_mode = true;
            tappy_mode = true;
            use_mpris_filter = true;
          };
          world_clock.type = "noctalia/world_clock:bar";
          herdr.type = "hy4ri/herdr:bar";
          wallhaven.type = "noctalia/wallhaven:wallhaven";
          awwwall.type = "0lucasmatheus/awwwall:toggle";
        };
      }

      (lib.mkIf isLaptop {
        bar.main.end = lib.mkForce ([ "battery" ] ++ endWidgets);
      })
    ];
  };
}
