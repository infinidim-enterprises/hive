{ lib, pkgs, ... }:
with lib;

mkMerge [
  {
    home.packages = with pkgs; [
      vlc
      v4l-utils
      lollypop
      id3v2
    ];
  }

  {
    home.packages = with pkgs; [ transmission_4-gtk ];
    xdg.mimeApps.associations.added."x-scheme-handler/magnet" = "transmission-gtk.desktop";
    xdg.mimeApps.defaultApplications."x-scheme-handler/magnet" = "transmission-gtk.desktop";
  }

]
