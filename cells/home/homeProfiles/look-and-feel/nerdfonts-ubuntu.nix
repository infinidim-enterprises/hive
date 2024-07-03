{ lib, pkgs, config, osConfig, localLib, ... }:
let
  inherit (config.home.sessionVariables)
    HM_FONT_NAME
    HM_FONT_SIZE;
  inherit (lib // builtins)
    mkMerge
    mkIf
    mkBefore
    elem
    toInt
    toString;
  inherit (localLib)
    pkgInstalled
    fontPkg
    isGui;

  font-size = toString ((toInt HM_FONT_SIZE) + 3);
  combinedPkgs = config.home.packages ++ osConfig.environment.systemPackages;
  fontStr = HM_FONT_NAME + " " + HM_FONT_SIZE;
  fontStrXterm = "xft:${HM_FONT_NAME}:pixelsize=${toString ((toInt HM_FONT_SIZE) + 5)}:antialias=true:hinting=true";
in
mkMerge [
  {
    xresources.properties."Xft.antialias" = 1;
    xresources.properties."Xft.dpi" = 96;
    xresources.properties."Xft.hinting" = 1;
    xresources.properties."Xft.hintstyle" = "hintslight";
    xresources.properties."Xft.lcdfilter" = "lcddefault";
    xresources.properties."Xft.rgba" = "rgb";
  }

  (mkIf config.programs.wlogout.enable {
    #           background-size: 15%;
    /*
      * {
          border-style: solid;
          border-width: 1px;
          border-color: @borders;
          background: @theme_base_color;
          color: @theme_text_color;
          font-family: ${HM_FONT_NAME};
          font-weight: bold;
      }

    */
    programs.wlogout.style = mkBefore ''
      window {
          color: @theme_text_color;
          background-color: @theme_base_color;
          font-family: ${HM_FONT_NAME};
          font-size: ${font-size}px;
      }

      button {
          margin: 5px;
          color: @theme_text_color;
          background-color: @theme_base_color;
          background-size: 20%;
          background-repeat: no-repeat;
          background-position: center;
          border: 5px solid @borders;
          border-radius: 15px;
          box-shadow: none;
          text-shadow: none;
          opacity: 0.9;
          transition: background-color 0.2s ease-in-out;
      }

      button:focus, button:active, button:hover {
          color: @theme_base_color;
          background-color: @theme_text_color;
          text-shadow: none;
          font-weight: bold;
      }

      #lock {
          background-image: image(url("${./wlogout_icons/lock.png}"));
      }

      #lock:hover, #lock:focus {
          background-image: image(url("${./wlogout_icons/lock-hover.png}"));
      }

      #logout {
          background-image: image(url("${./wlogout_icons/logout.png}"));
      }
      #logout:hover, #logout:focus {
          background-image: image(url("${./wlogout_icons/logout-hover.png}"));
      }

      #suspend {
          background-image: image(url("${./wlogout_icons/suspend.png}"));
      }
      #suspend:hover, #suspend:focus {
          background-image: image(url("${./wlogout_icons/suspend-hover.png}"));
      }

      #hibernate {
          background-image: image(url("${./wlogout_icons/hibernate.png}"));
      }
      #hibernate:hover, #hibernate:focus {
          background-image: image(url("${./wlogout_icons/hibernate-hover.png}"));
      }

      #shutdown {
          background-image: image(url("${./wlogout_icons/shutdown.png}"));
      }
      #shutdown:hover, #shutdown:focus {
          background-image: image(url("${./wlogout_icons/shutdown-hover.png}"));
      }

      #reboot {
          background-image: image(url("${./wlogout_icons/reboot.png}"));
      }
      #reboot:hover, #reboot:focus {
          background-image: image(url("${./wlogout_icons/reboot-hover.png}"));
      }

    '';
  })

  (mkIf config.programs.waybar.enable {
    # border-radius: 20px;
    programs.waybar.style = mkBefore ''
      * {
        border: none;
        padding-left: 7px;
        padding-right: 7px;

        font-family:
          ${HM_FONT_NAME}, FontAwesome;
        font-size: ${font-size}px;
        min-height: 0;
      }
    '';
  })

  (mkIf config.services.dunst.enable {
    services.dunst.settings.global.font = fontStr;
  })

  (mkIf config.programs.vscode.enable
    {
      programs.vscode.userSettings."editor.fontFamily" = HM_FONT_NAME;
      programs.vscode.userSettings."editor.fontSize" = (toInt HM_FONT_SIZE);
    }
  )

  (mkIf config.gtk.enable {
    gtk.font.name = HM_FONT_NAME;
    gtk.font.size = toInt HM_FONT_SIZE;
    gtk.font.package = fontPkg { name = "nerdfonts"; inherit osConfig; };
  })

  (mkIf config.programs.firefox.enable {
    programs.firefox.profiles.default.settings = {
      "font.default.x-western" = "sans-serif";
      "font.name.sans-serif.x-western" = HM_FONT_NAME;
      "font.name.serif.x-western" = HM_FONT_NAME;
      "font.size.fixed.x-western" = (toInt HM_FONT_SIZE);
      "font.size.monospace.x-western" = (toInt HM_FONT_SIZE);
      "font.size.variable.x-western" = (toInt HM_FONT_SIZE);
    };
  })

  # TODO: (mkIf config.programs.chromium.enable { })

  (mkIf config.programs.rofi.enable {
    programs.rofi.font =
      if osConfig.deploy.params.hidpi.enable
      then (HM_FONT_NAME + " " + (toString ((toInt HM_FONT_SIZE) * 2)))
      else fontStr;
  })

  (mkIf (pkgInstalled { pkg = pkgs.tilix;inherit combinedPkgs; }) { dconf.settings."com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d".font = fontStr; })
  (mkIf config.programs.kitty.enable {
    programs.kitty.font.name = HM_FONT_NAME;
    programs.kitty.font.size = toInt HM_FONT_SIZE;
  })

  (mkIf (pkgInstalled { pkg = pkgs.xterm; inherit combinedPkgs; }) {
    xresources.properties."XTerm*utf8" = "1";
    xresources.properties."XTerm*utf8Title" = "true";
    xresources.properties."XTerm*utf8Fonts" = "true";
    xresources.properties."XTerm*utf8Latin1" = "true";
    xresources.properties."XTerm*faceName" = fontStrXterm;
    xresources.properties."XTerm*faceNameDoublesize" = fontStrXterm;
  })

  (mkIf (isGui osConfig) {
    dconf.settings = {
      # "org/mate/desktop/peripherals/keyboard/indicator".font-family = fontStr;
      # "org/gnome/desktop/interface".font-name = fontStr;
      "org/mate/desktop/interface" = {
        font-name = fontStr;
        document-font-name = fontStr;
        monospace-font-name = fontStr;
      };
      "org/mate/desktop/font-rendering" = {
        antialiasing = "rgba";
        hinting = "slight";
      };
      "org/mate/marco/general".titlebar-font =
        HM_FONT_NAME
        + " "
        + (toString ((toInt HM_FONT_SIZE) - 6));
    };
  })
]
