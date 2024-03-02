{ config, lib, pkgs, ... }:

lib.mkMerge [
  {
    home.packages = with pkgs;[
      remmina
      nx-libs
      # xorg.xorgserver
    ];
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
