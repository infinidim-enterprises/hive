#{
# TODO: https://github.com/morhetz/gruvbox - it's a lot better than solarized-dark crap I'm using!
# pkgs.gruvbox-dark-gtk pkgs.gruvbox-dark-icons-gtk
# also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=themix-full-git
# For everything https://github.com/morhetz/gruvbox-contrib
#}
{ osConfig ? { }, config, lib, pkgs, ... }:
# with lib;
# hmLib = import <home-manager/modules/lib/stdlib-extended.nix> pkgs.lib
let
  isHostConfig = osConfig != { };
  inherit (lib) mkIf mkMerge elem;
  inherit (builtins) readFile;
  # isDircolors = config.programs.dircolors.enable;
  # xdg = config.xdg;

  # TODO: *# 00;38;5;240 and empty lines handling
  commonDefaults = { gtk-theme = "NumixSolarizedDarkGreen"; icon-theme = "Numix-Circle"; };
in
mkMerge [
  (mkIf config.programs.vscode.enable { programs.vscode.userSettings."workbench.colorTheme" = "Solarized Dark"; })
  (mkIf (isHostConfig && osConfig.services.xserver.desktopManager.mate.enable) {
    dconf.settings."org/gnome/desktop/interface" = commonDefaults;
    dconf.settings."org/mate/desktop/interface" = commonDefaults;
    # dconf.settings."org/mate/desktop/background"
    # NOTE: https://wiki.archlinux.org/title/Cursor_themes#Desktop_environments
  })

  (mkIf config.programs.bat.enable {
    programs.bat.config.theme = "Solarized (dark)";
    programs.bat.themes.solarized = readFile "${pkgs.sources.sublimeSolarized.src}/Solarized (dark).sublime-color-scheme";
  })

  (mkIf config.programs.git.delta.enable {
    programs.git.delta.options.features = "decorations";
    programs.git.delta.options.syntax-theme = "Solarized (dark)";
  })

  (mkIf config.programs.kitty.enable {
    programs.kitty.settings = {
      cursor = "#93a1a1";
      background = "#002b36";
      foreground = "#839496";
      selection_background = "#839496";
      selection_foreground = "#002b36";
      color0 = "#073642";
      color1 = "#dc322f";
      color2 = "#859900";
      color3 = "#b58900";
      color4 = "#268bd2";
      color5 = "#d33682";
      color6 = "#2aa198";
      color7 = "#eee8d5";
      color8 = "#002b36";
      color9 = "#cb4b16";
      color10 = "#586e75";
      color11 = "#657b83";
      color12 = "#839496";
      color13 = "#6c71c4";
      color14 = "#93a1a1";
      color15 = "#fdf6e3";
    };
  })

  (mkIf config.programs.rofi.enable { programs.rofi.theme = "solarized"; })
  (mkIf (elem pkgs.tilix config.home.packages) {
    dconf.settings."com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-color = "#002b36";
      foreground-color = "#839496";

      # palette = lib.hm.gvariant.mkArray "" [
      #   "#063541"
      #   "#DB312E"
      #   "#849900"
      #   "#B48800"
      #   "#258AD1"
      #   "#D23581"
      #   "#29A097"
      #   "#EDE7D4"
      #   "#002A35"
      #   "#CA4A15"
      #   "#576D74"
      #   "#647A82"
      #   "#829395"
      #   "#6B70C3"
      #   "#92A0A0"
      #   "#FCF5E2"
      # ];

    };
  })
  (mkIf (isHostConfig && (elem pkgs.xterm osConfig.environment.systemPackages)) {
    xresources.properties = {
      # just in case xterm is needed!
      "XTerm.termName" = "xterm-256color";
      "XTerm*bellIsUrgent" = "true";
      "XTerm*locale" = "true";
      "XTerm*dynamicColors" = "true";
      "XTerm*eightBitInput" = "true";
      "XTerm*saveLines" = "10000";
      "XTerm**charClass" = "33:48,35:48,37:48,43:48,45-47:48,61:48,63:48,64:48,95:48,126:48,35:48,58:48";

      # Solarized palette
      #!! black dark/light
      "*color0" = "#073642";
      "*color8" = "#002b36";
      #!! red dark/light
      "*color1" = "#dc322f";
      "*color9" = "#cb4b16";
      #!! green dark/light
      "*color2" = "#859900";
      "*color10" = "#586e75";
      #!! yellow dark/light
      "*color3" = "#b58900";
      "*color11" = "#657b83";
      #!! blue dark/light
      "*color4" = "#268bd2";
      "*color12" = "#839496";
      #!! magenta dark/light
      "*color5" = "#d33682";
      "*color13" = "#6c71c4";
      #!! cyan dark/light
      "*color6" = "#2aa198";
      "*color14" = "#93a1a1";
      #!! white dark/light
      "*color7" = "#eee8d5";
      "*color15" = "#fdf6e3";
      # base setup
      "*foreground" = "#839496";
      "*background" = "#002b36";
      "*fadeColor" = "#002b36";
      "*cursorColor" = "#93a1a1";
      "*pointerColorBackground" = "#586e75";
      "*pointerColorForeground" = "#93a1a1";
    };
  })
]
