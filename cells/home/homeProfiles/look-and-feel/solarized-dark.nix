{ osConfig, config, lib, localLib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge elem;
  inherit (localLib) isGui;
  inherit (builtins) readFile;
  pkgInstalled = pkg:
    elem pkg (config.home.packages ++ osConfig.environment.systemPackages);

  # TODO: *# 00;38;5;240 and empty lines handling
  # "org/gnome/desktop/interface".gtk-theme = "Solarized-Dark-Green-GS-3.36";
  # commonDefaults = { gtk-theme = "NumixSolarizedDarkGreen"; icon-theme = "Numix-Circle"; };
  commonDefaults = { gtk-theme = "Solarized-Dark-Green-GS-3.36"; icon-theme = "Numix-Circle"; };
in
mkMerge [
  #  { home.packages = [ pkgs.numix-solarized-gtk-theme ]; }
  (mkIf config.programs.vscode.enable { programs.vscode.userSettings."workbench.colorTheme" = "Solarized Dark"; })
  (mkIf (isGui osConfig) {
    dconf.settings."org/mate/desktop/peripherals/keyboard/indicator" = {
      foreground-color = "131 148 150";
      background-color = "0 0 0"; ### FIXME: invalid color and 0 43 54 doesnt work
    };
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
  (mkIf (pkgInstalled pkgs.tilix) {
    dconf.settings."com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-color = "#002b36";
      foreground-color = "#839496";

      # FIXME: tilix is dead, find something better!
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
  (mkIf (pkgInstalled pkgs.xterm) {
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
