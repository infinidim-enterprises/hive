{ inputs, cell }:

{ osConfig, config, lib, localLib, pkgs, ... }:
let
  inherit (lib // builtins)
    readFile
    mkIf
    mkMerge
    elem
    fileContents
    toInt
    mkAfter
    hasAttr;
  inherit (localLib) isGui pkgInstalled;
  inherit (inputs.cells.common.lib) hexToRgba;

  combinedPkgs = config.home.packages ++ osConfig.environment.systemPackages;
  commonDefaults = { gtk-theme = "NumixSolarizedDarkGreen"; icon-theme = "Numix-Circle"; };
  # NOTE: https://gitlab.gnome.org/GNOME/gtk/-/blob/gtk-3-24/gtk/theme/Adwaita/_colors-public.scss
in
mkMerge [
  {
    qt.enable = true;
    qt.platformTheme.name = "gtk";
    qt.style.name = "gtk2";

    gtk.enable = true;

    gtk.cursorTheme.size = 32;
    gtk.cursorTheme.name = "Numix-Cursor-Light";
    gtk.cursorTheme.package = pkgs.numix-cursor-theme;

    gtk.iconTheme.name = "Numix-Circle";
    gtk.iconTheme.package = pkgs.numix-icon-theme-circle;

    gtk.theme.name = "NumixSolarizedDarkGreen";
    gtk.theme.package = pkgs.numix-solarized-gtk-theme;

    # NOTE: https://ghostarchive.org/archive/p2BmM
    # https://github.com/glacambre/firefox-patches/issues/1
    # https://docs.gtk.org/gtk3/class.Settings.html#properties
    # https://docs.gtk.org/gtk4/class.Settings.html
    /*
      GTK2:
      gtk-theme-name="Solarized-Dark-Green-3.36"
      gtk-icon-theme-name="Adwaita"
      gtk-cursor-theme-name="Adwaita"
      gtk-font-name="UbuntuMono Nerd Font Mono 15"
      gtk-menu-images=0
      gtk-cursor-theme-size=32
      gtk-button-images=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="none"
      gtk-xft-dpi=98304
      --------
      GTK3:
      gtk-3.0/settings.ini
      [Settings]
      gtk-theme-name=Solarized-Dark-Green-3.36
      gtk-application-prefer-dark-theme=false
      gtk-icon-theme-name=Adwaita
      gtk-cursor-theme-name=Adwaita
      gtk-cursor-theme-size=32
      gtk-font-name=UbuntuMono Nerd Font Mono 15
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=none
      gtk-xft-dpi=98304
      gtk-overlay-scrolling=true
      gtk-key-theme-name=Emacs
      gtk-menu-images=false
      gtk-button-images=false
      ------
      GTK4:
      [Settings]
      gtk-theme-name=Solarized-Dark-Green-3.36
      gtk-application-prefer-dark-theme=false
      gtk-icon-theme-name=Adwaita
      gtk-cursor-theme-name=Adwaita
      gtk-cursor-theme-size=32
      gtk-font-name=UbuntuMono Nerd Font Mono 15
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=none
      gtk-xft-dpi=98304
      gtk-overlay-scrolling=true

    */
    # NOTE: GTK2_RC_FILES aren't always respected!
    # gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk.gtk2.extraConfig = ''
      gtk-key-theme-name = "Emacs"
      binding "gtk-emacs-text-entry"
      {
        bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) }
      }
    '';

    # TODO: gtk.gtk3.extraCss = fileContents ./gtk3.gtk_css;
  }

  (mkIf config.programs.waybar.enable {
    programs.waybar.style = mkAfter ''
      window#waybar {
          background: @theme_base_color;
          border-bottom: 1px solid @unfocused_borders;
          color: @theme_text_color;
      }

      #clock.calendar, #calendar {
          background: @theme_base_color;
      }

      tooltip {
          background: @theme_base_color;
      }
    '';
  })

  (mkIf config.services.dunst.enable {
    services.dunst.iconTheme.name = config.gtk.iconTheme.name;
    services.dunst.iconTheme.package = config.gtk.iconTheme.package;
  })

  (mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland.settings.general = {
      "col.active_border" = "rgba(839496FF)";
      "col.inactive_border" = "rgba(002b36ff)";
    };
  })

  (mkIf config.programs.vscode.enable { programs.vscode.userSettings."workbench.colorTheme" = "Solarized Dark"; })

  (mkIf (isGui osConfig) {
    dconf.settings."org/mate/desktop/peripherals/keyboard/indicator" = {
      foreground-color = "131 148 150";
      background-color = "0 0 0"; ### FIXME: invalid color and 0 43 54 doesnt work
    };
    dconf.settings."org/gnome/desktop/interface" = commonDefaults;
    dconf.settings."org/mate/desktop/interface" = commonDefaults;
    # dconf.settings."org/mate/desktop/background"
  })

  (mkIf config.programs.bat.enable {
    programs.bat.config.theme = "Solarized (dark)";
    programs.bat.themes.solarized = {
      inherit (pkgs.sources.sublimeSolarized) src;
      file = "Solarized (dark).sublime-color-scheme";
    };
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

  (mkIf (pkgInstalled { pkg = pkgs.tilix; inherit combinedPkgs; }) {
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

  (mkIf (pkgInstalled { pkg = pkgs.xterm; inherit combinedPkgs; }) {
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

  (mkIf (hasAttr "waveterm" config.programs && config.programs.waveterm.enable) {
    programs.waveterm.settings."term:theme" = "solarized-dark";
    programs.waveterm.settings."tab:preset" = "bg@solarized-dark";
    programs.waveterm.settings."term:transparency" = 0;
    programs.waveterm.settings."window:bgcolor" = "#002b36";
    programs.waveterm.settings."window:reducedmotion" = true;
    programs.waveterm.settings."window:tilegapsize" = 1;

    programs.waveterm.presets."bg@solarized-dark" = {
      "display:name" = "Solarized Dark";
      "display:order" = -2;

      "bg:*" = true;
      "bg" = hexToRgba "#002b36";
      "bg:text" = hexToRgba "#839496";
      "bg:opacity" = 1.0;
      "bg:activebordercolor" = hexToRgba "#839496";
    };

    programs.waveterm.termthemes."solarized-dark" = {
      "display:name" = "Solarized Dark";
      "display:order" = -1;

      "background" = "#002b36";
      "foreground" = "#839496";

      "selectionBackground" = "#073642";
      "cursor" = "#93a1a1";

      "black" = "#073642";
      "brightBlack" = "#002b36";
      "white" = "#eee8d5";
      "brightWhite" = "#fdf6e3";
      "red" = "#dc322f";
      "brightRed" = "#cb4b16";
      "green" = "#859900";
      "brightGreen" = "#586e75";
      "yellow" = "#b58900";
      "brightYellow" = "#657b83";
      "blue" = "#268bd2";
      "brightBlue" = "#839496";
      "magenta" = "#d33682";
      "brightMagenta" = "#6c71c4";
      "cyan" = "#2aa198";
      "brightCyan" = "#93a1a1";

      # "gray" = "#8b918a";
      # "cmdtext" = "#f0f0f0";
    };

    /*
      base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
      base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26

      base01    #586e75 10/7 brgreen  240 #585858 45 -07 -07  88 110 117 194  25  46
      base00    #657b83 11/7 bryellow 241 #626262 50 -07 -07 101 123 131 195  23  51
      base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
      base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63

      base2     #eee8d5  7/7 white    254 #e4e4e4 92 -00  10 238 232 213  44  11  93
      base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99

      yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
      orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
      red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
      magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
      violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
      blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
      cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
      green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60

    */
  })

  (mkIf config.programs.dircolors.enable {
    programs.dircolors.extraConfig = fileContents "${pkgs.sources.dircolors-solarized.src}//dircolors.256dark";
  })
]
