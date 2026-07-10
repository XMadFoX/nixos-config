{ lib, osConfig, ... }:

let
  isTsiteli = osConfig.networking.hostName == "tsiteli";

  # Bar widgets shown on the right/end section (v5 widget IDs).
  endWidgets = [
    "network"
    "bluetooth"
    "cpu"
    "ram"
    "control-center"
  ];
in
{
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
        };

        bar.main = {
          position = "top";
          thickness = 30;
          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "clock"
            "volume"
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

        wallpaper = {
          # managed externally, dont let noctalia override
          enabled = false;
        };
      }

      (lib.mkIf isTsiteli {
        bar.main.end = lib.mkForce ([ "battery" ] ++ endWidgets);
      })
    ];
  };
}
