{ pkgs, config, lib, ... }:
let
  inherit (lib)
    mkMerge
    mkIf
    genAttrs;
  images = [
    "image/bmp"
    "image/gif"
    "image/jpeg"
    "image/jpg"
    "image/pjpeg"
    "image/png"
    "image/tiff"
    "image/x-bmp"
    "image/x-gray"
    "image/x-icb"
    "image/x-ico"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
    "image/x-pcx"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/vnd.wap.wbmp;image/x-icns"
  ];

in

mkMerge [
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
      gimp3-with-plugins # The GNU Image Manipulation Program
      imagemagick # A software suite to create, edit, compose, or convert bitmap images
      (freecad.override {
        qtVersion = 6;
        ifcSupport = true;
        withWayland = true;
      })
      # krita # A free and open source painting application
      themix-gui # Graphical application for designing themes and exporting them using plugins
    ];
  }

  (mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications = genAttrs images (_: "org.nomacs.ImageLounge.desktop");
    xdg.mimeApps.associations.added = genAttrs images (_: [
      "org.nomacs.ImageLounge.desktop"
      "gimp.desktop"
    ]);
  })
]
