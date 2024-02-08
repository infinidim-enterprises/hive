{ self, config, lib, pkgs, ... }:
# TODO: export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5
#
with lib;
let
  addToXDGDirs = p: ''
    if [ -d "${p}/share/gsettings-schemas/${p.name}" ]; then
      export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${p}/share/gsettings-schemas/${p.name}
    fi

    if [ -d "${p}/lib/girepository-1.0" ]; then
      export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}${p}/lib/girepository-1.0
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${p}/lib
    fi
  '';

  cfg = config.services.xserver.windowManager.stumpwm;
  cfgHm = config ? home-manager;

  fontPkg = pkgs.symlinkJoin {
    name = "hmLocalFontsDir";
    paths = config.fonts.packages;
  };

  fontsDir = pkgs.runCommandNoCC "fonts-dir" { } ''
    mkdir $out
    find ${fontPkg}/share/fonts/truetype/NerdFonts/Ubuntu*.* -print0 |
      while read -d $'\0' file
      do
        fn=$out/$(basename "$file")
        ln -s -f "$file" "$fn"
      done
  '';

  stumpwm_desktop =
    let
      ### TODO:  https://github.com/mate-desktop/mate-panel/blob/36be054255ff728061c056899c052c790ed43ae1/mate-panel/panel-schemas.h#L50
      # relative-to-edge is available in dev versions, instead of panel-right-stick
      customDconf = pkgs.writeText "customDconf" ''
        [ca/desrt/dconf-editor]
        show-warning=false

        [org/mate/desktop/background]
        draw-background=false
        show-desktop-icons=false

        [org/mate/desktop/session]
        required-components-list=['windowmanager', 'panel']
        gnome-compat-startup=['smproxy']

        [org/mate/desktop/session/required-components]
        windowmanager='stumpwm'
        panel='mate-panel'

        [org/mate/panel/general]
        object-id-list=['menu-bar', 'notification-area', 'clock']
        toplevel-id-list=['top']

        [org/mate/panel/objects/clock]
        position=0
        locked=true
        toplevel-id='top'
        object-type='applet'
        panel-right-stick=true
        applet-iid='ClockAppletFactory::ClockApplet'

        [org/mate/panel/objects/menu-bar]
        toplevel-id='top'
        locked=true
        position=0

        [org/mate/panel/objects/notification-area]
        position=1
        locked=true
        toplevel-id='top'
        object-type='applet'
        panel-right-stick=true
        applet-iid='NotificationAreaAppletFactory::NotificationArea'

        [org/mate/panel/toplevels/top]
        screen=0
        expand=true
        x-centered=true
        orientation='top'

        [org/mate/caja/preferences]
        enable-delete=true
        confirm-trash=false
        default-folder-viewer='list-view'

        [org/mate/notification-daemon]
        popup-location='top_right'
        theme='standard'
      '';

      stumpwm-mate-script = pkgs.writeShellScriptBin "stumpwm-mate" ''
        if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
          echo "STUMPWM: Registering with Mate Session Manager via Dbus id $DESKTOP_AUTOSTART_ID"
          ${pkgs.dbus}/bin/dbus-send --session \
            --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.RegisterClient "string:stumpwm" "string:$DESKTOP_AUTOSTART_ID"
        else
          echo "DESKTOP_AUTOSTART_ID not set."
        fi
        ${cfg.package}/bin/stumpwm-lisp-launcher.sh \
          --eval '(declaim #+sbcl(sb-ext:muffle-conditions style-warning))' \
          --eval '(require :stumpwm)' \
          --eval '(defun stumpwm::data-dir () (merge-pathnames "Logs/" (user-homedir-pathname)))' \
          --eval '(stumpwm:stumpwm)' \
          --eval '(quit)'
      '';

      mate-session-script = pkgs.writeShellScript "mate-session-script" ''
        ${pkgs.dconf}/bin/dconf load / < ${customDconf}
        ${pkgs.mate.mate-session-manager}/bin/mate-session
      '';

      icons = pkgs.stdenvNoCC.mkDerivation {
        name = "stumpwm-logo-shared-icons";
        buildInputs = [ pkgs.imagemagick ];
        phases = [ "installPhase" ];
        src = pkgs.fetchurl {
          url = "https://stumpwm.github.io/images/stumpwm-logo-stripe.png";
          sha256 = "05p9l5zmmrhisw83d3r8iq0174j1nqaby61cqdixkpflkg92rirm";
        };

        installPhase = ''
          for res in 512 256 128 48 32 24 16
          do
            resolution="''${res}x''${res}"
            target_dir="$out/share/icons/hicolor/''${resolution}/apps"
            mkdir -p "$target_dir"
            convert $src -resize "$resolution" "''${target_dir}/stumpwm.png"
          done
        '';
      };

      item = pkgs.makeDesktopItem {
        name = "stumpwm";
        icon = "stumpwm";
        desktopName = "stumpwm";
        exec = "${stumpwm-mate-script}/bin/stumpwm-mate";
        type = "Application";
        noDisplay = true;
        extraConfig = {
          X-MATE-WMName = "stumpwm";
          X-MATE-Autostart-Phase = "WindowManager";
          X-MATE-Provides = "windowmanager";
          X-MATE-Autostart-Notify = "false";
        };
      };

      xsession = {
        name = "stumpwm";
        desktopNames = [ "MATE" ];
        bgSupport = true;
        start = "${mate-session-script}";
      };
    in
    { inherit xsession icons item; };

in
{
  options.services.xserver.windowManager.stumpwm = with types; {
    enable = mkEnableOption "StumpWM";
    package = mkOption {
      type = package;
      default = pkgs.stumpwmCustomBuild;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      xdg.mime.enable = true;
      services.xserver = {
        layout = "us";
        enable = true;
        updateDbusEnvironment = true;
        desktopManager.mate.enable = true;
        desktopManager.session = singleton stumpwm_desktop.xsession;
        gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
      };

      services.gnome.glib-networking.enable = true;

      environment.sessionVariables.CPATH = "${pkgs.libfixposix}/include";
      environment.systemPackages = [ cfg.package stumpwm_desktop.item stumpwm_desktop.icons ];
      environment.mate.excludePackages = with pkgs.mate; [
        atril
        mate-terminal
        mate-backgrounds
        mate-user-guide
        mate-calc
        pluma
      ];
    })

    (mkIf (cfgHm && cfg.enable) {
      home-manager.sharedModules = [
        ({ name, config, lib, ... }:
          let
            cfg = config.services.xserver.windowManager.stumpwm;
            cfgEmacs = config.programs.emacs.enable;
            cfgOpenSnitch = config.services ? opensnitch;
            cfgMimeApps = config.xdg.mimeApps.enable;
          in
          {
            options.services.xserver.windowManager.stumpwm.confDir = with lib.types; lib.mkOption {
              default = let tPath = "${self}/users/${name}/dotfiles/stumpwm.d"; in if builtins.pathExists tPath then tPath else null;
              type = nullOr (oneOf [ path string ]);
              apply = v: if v != null then builtins.toPath v else null;
              description = "Path to stumpwm config dir";
            };

            config = lib.mkMerge [
              (lib.mkIf cfgMimeApps {
                xdg.mimeApps.defaultApplications."inode/directory" = "caja-folder-handler.desktop";
                xdg.mimeApps.defaultApplications."application/x-mate-saved-search" = "caja-folder-handler.desktop";
              })

              (lib.mkIf cfgOpenSnitch {
                services.opensnitch.allow =
                  with builtins;
                  let
                    withDir = dir: map (x: "${dir}/${x}") (filter (hasPrefix ".") (attrNames (readDir dir)));
                  in
                  flatten (map withDir [
                    "${pkgs.mate.mate-panel}/libexec"
                    "${pkgs.gvfs}/libexec"
                  ]);
              })

              (lib.mkIf (!builtins.isNull cfg.confDir) {
                xdg.configFile."stumpwm".source = cfg.confDir;
                xdg.configFile."stumpwm".recursive = true;
                xdg.configFile."common-lisp/asdf-output-translations.conf.d/99-disable-cache.conf".text = ":disable-cache";
                xdg.dataFile."fonts".source = fontsDir;
              })

              # (mkIf cfgEmacs {
              #   programs.emacs.extraPackages = (p: with p; [
              #     sly
              #     sly-asdf
              #     sly-macrostep
              #     sly-named-readtables
              #     sly-quicklisp
              #     sly-repl-ansi-color
              #   ]);
              # })

            ];
          }
        )
      ];
    })

  ];
}
