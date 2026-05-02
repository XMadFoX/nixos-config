{
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "top";
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            { id = "Network"; }
            { id = "Bluetooth"; }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "none";
            }
          ];
          right = [
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      # colorSchemes.predefinedScheme = "";
      general = {
        avatarImage = "/home/madfox/.face";
        radiusRatio = 0.4;
      };
      location = {
        monthBeforeDay = false;
        name = "Tbilisi, Georgia";
      };
    };
  };
}
