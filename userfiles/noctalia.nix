{ lib, osConfig, ... }:

let
  isTsiteli = osConfig.networking.hostName == "tsiteli";

  rightWidgets = [
    { id = "Network"; }
    { id = "Bluetooth"; }
    { id = "SystemMonitor"; }
    {
      id = "ControlCenter";
      useDistroLogo = true;
    }
  ];
in
{
  programs.noctalia-shell = {
    enable = true;
    settings = lib.mkMerge [
      {
        bar = {
          density = "compact";
          position = "top";
          widgets = {
            left = [
              {
                id = "Workspace";
                hideUnoccupied = false;
                labelMode = "none";
              }
              { id = "ActiveWindow"; }
            ];
            center = [
              {
                id = "Clock";
                formatHorizontal = "HH:mm";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
              { id = "Volume"; }
            ];
            right = rightWidgets;
          };
        };
        # colorSchemes.predefinedScheme = "";
        general = {
          avatarImage = "/home/madfox/.face";
          radiusRatio = 0.4;
        };
        dock = {
          enabled = false;
          showLauncherIcon = false;
        };
        appLauncher = {
          # Noctalia has no top-level appLauncher.enabled option in this flake;
          # keep every optional launcher integration/search provider off.
          enableClipboardHistory = false;
          enableSettingsSearch = false;
          enableWindowsSearch = false;
          enableSessionSearch = false;
        };
        location = {
          monthBeforeDay = false;
          name = "Tbilisi, Georgia";
        };
        wallpaper = {
          # managed externaly, dont let noctalia override
          enabled = false;
        };
      }

      (lib.mkIf isTsiteli {
        bar.widgets.right = lib.mkForce (
          [
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
          ]
          ++ rightWidgets
        );
      })
    ];
  };
}
