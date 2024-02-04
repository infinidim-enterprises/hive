{ lib, ... }:
with lib;
mkMerge [
  {
    xdg.enable = true;
    xdg.mime.enable = true;
    xdg.mimeApps.enable = true;
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;
  }

  {
    xdg.mimeApps.associations.added."application/pdf" = "org.gnome.Evince.desktop";
    xdg.mimeApps.defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
  }
]
