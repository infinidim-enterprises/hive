{ config, lib, pkgs, ... }:

lib.mkMerge [
  {
    services.remmina.enable = true;
    systemd.user.services.remmina.Unit.After = [ "waybar.service" ];

    home.packages = with pkgs; [ nx-libs ];
  }

  (lib.mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.associations.added = {
      "x-scheme-handler/rdp" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/spice" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/vnc" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/remmina" = "org.remmina.Remmina.desktop";
      "application/x-remmina" = "org.remmina.Remmina.desktop";
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/rdp" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/spice" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/vnc" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/remmina" = "org.remmina.Remmina.desktop";
      "application/x-remmina" = "org.remmina.Remmina.desktop";
    };
  })
]
