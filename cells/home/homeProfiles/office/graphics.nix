{ pkgs, config, ... }:
{
  # services.flameshot.enable = true;
  # services.flameshot.package = pkgs.flameshot;
  # services.flameshot.settings = {
  #   # NOTE: https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
  #   General = {
  #     savePath = "${config.xdg.userDirs.pictures}/screenshots";
  #     saveAsFileExtension = ".jpg";
  #     useJpgForClipboard = true;
  #     jpegQuality = 75;
  #     showHelp = false;
  #     showDesktopNotification = true;
  #     filenamePattern = "%F_%H-%M";
  #     disabledTrayIcon = false;
  #     showStartupLaunchMessage = false;
  #   };
  # };

  home.packages = with pkgs; [
    nomacs # Qt-based image viewer
    inkscape # Vector graphics editor
    gimp-with-plugins # The GNU Image Manipulation Program
    imagemagick # A software suite to create, edit, compose, or convert bitmap images
    # krita # A free and open source painting application
  ];
}
