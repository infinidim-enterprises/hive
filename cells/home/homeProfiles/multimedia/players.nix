{ lib, pkgs, config, ... }:
with lib;

mkMerge [
  (mkIf config.programs.zsh.enable {
    programs.zsh.shellAliases.ytget = "${pkgs.yt-dlp}/bin/yt-dlp --no-update --write-description --progress --sponsorblock-remove all";
  })

  {
    home.packages = with pkgs; [
      vlc
      v4l-utils
      ffmpeg-full

      aria2 # --downloader aria2 for yt-dlp
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites
      id3v2 # mp3 tag manipulator
    ];
  }

  {
    home.packages = with pkgs; [ transmission_4-gtk ];
    xdg.mimeApps.associations.added."x-scheme-handler/magnet" = "transmission-gtk.desktop";
    xdg.mimeApps.defaultApplications."x-scheme-handler/magnet" = "transmission-gtk.desktop";
  }

]
