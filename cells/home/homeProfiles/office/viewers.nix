{ pkgs, lib, config, ... }:

lib.mkMerge
  [
    (lib.mkIf config.xdg.mimeApps.enable {
      xdg.mimeApps.associations.added."application/pdf" = "org.gnome.Evince.desktop";
      xdg.mimeApps.defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
    })
    {
      home.packages = with pkgs; [
        font-manager # Simple font management for GTK desktop environments
        foliate # A simple and modern GTK eBook reader
        evince # GNOME's document viewer

        # REVIEW: okular # KDE thing, maybe? pdf reader
      ];
    }
  ]
