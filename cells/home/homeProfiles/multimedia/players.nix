{ lib, pkgs, ... }:
with lib;

mkMerge [
  {
    home.packages = with pkgs; [
      vlc
      v4l-utils
      ffmpeg-full

      yt-dlp # Command-line tool to download videos from YouTube.com and other sites
      # FIXME: lollypop # audio player
      id3v2 # mp3 tag manipulator
    ];
  }

  {
    home.packages = with pkgs; [ transmission_4-gtk ];
    xdg.mimeApps.associations.added."x-scheme-handler/magnet" = "transmission-gtk.desktop";
    xdg.mimeApps.defaultApplications."x-scheme-handler/magnet" = "transmission-gtk.desktop";
  }

]
