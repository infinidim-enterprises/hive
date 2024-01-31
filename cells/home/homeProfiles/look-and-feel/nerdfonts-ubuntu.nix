{ lib, pkgs, config, osConfig ? { }, ... }:
let
  isHostConfig = osConfig != { };

  inherit (config.home.sessionVariables) HM_FONT_NAME HM_FONT_SIZE;
  inherit (lib) mkMerge mkIf elem toInt;
  inherit (builtins) toString;

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

  (mkIf config.programs.vscode.enable
    {
      programs.vscode.userSettings."editor.fontFamily" = HM_FONT_NAME;
      programs.vscode.userSettings."editor.fontSize" = (toInt HM_FONT_SIZE);
    }
  )

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

  (mkIf (elem pkgs.tilix config.home.packages) { dconf.settings."com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d".font = fontStr; })
  (mkIf config.programs.kitty.enable {
    programs.kitty.font.name = HM_FONT_NAME;
    programs.kitty.font.size = toInt HM_FONT_SIZE;
  })
  (mkIf (isHostConfig && (elem pkgs.xterm osConfig.environment.systemPackages)) {
    xresources.properties."XTerm*utf8" = "1";
    xresources.properties."XTerm*utf8Title" = "true";
    xresources.properties."XTerm*utf8Fonts" = "true";
    xresources.properties."XTerm*utf8Latin1" = "true";
    xresources.properties."XTerm*faceName" = fontStrXterm;
    xresources.properties."XTerm*faceNameDoublesize" = fontStrXterm;
  })
  (mkIf
    (isHostConfig && osConfig.services.xserver.desktopManager.mate.enable)
    {
      dconf.settings = {
        "org/mate/desktop/peripherals/keyboard/indicator".font-family = fontStr;
        "org/gnome/desktop/interface".font-name = fontStr;
        "org/mate/desktop/interface" = {
          font-name = fontStr;
          document-font-name = fontStr;
          monospace-font-name = fontStr;
        };
        "org/mate/desktop/font-rendering" = {
          antialiasing = "rgba";
          hinting = "slight";
        };
        "org/mate/marco/general".titlebar-font = HM_FONT_NAME + " " + (toString ((toInt HM_FONT_SIZE) - 6));
      };
    })
]
