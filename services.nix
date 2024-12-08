{pkgs, ...}: {

  systemd.user.services.gammastepx = {
    description = "Gammastep";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session-pre.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.gammastep}/bin/gammastep -v -b 1.0:0.85 -t 4500:2500 -m wayland";
      Restart = "always";
    };
  };
}
