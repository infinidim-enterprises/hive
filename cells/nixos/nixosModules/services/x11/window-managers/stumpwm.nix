{ self, config, lib, pkgs, ... }:
# TODO: export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5
#
with lib;
let
  cfg = config.services.xserver.windowManager.stumpwm;
  cfgHm = hasAttr "home-manager" config;

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
      stumpwm-mate-script = pkgs.writeShellScript "stumpwm-mate" ''
        if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
          echo "STUMPWM: Registering with Mate Session Manager via Dbus id $DESKTOP_AUTOSTART_ID"
          ${pkgs.dbus}/bin/dbus-send --session \
            --dest=org.gnome.SessionManager \
            "/org/gnome/SessionManager" \
            org.gnome.SessionManager.RegisterClient \
            "string:stumpwm" \
            "string:$DESKTOP_AUTOSTART_ID"
        else
          echo "DESKTOP_AUTOSTART_ID not set."
        fi

        ${cfg.package}/bin/stumpwm
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

      desktopItemTemlate = {
        name = "stumpwm";
        desktopName = "stumpwm";
        keywords = [ "launch" "stumpwm" "desktop" "session" ];
        icon = "stumpwm";
        type = "Application";
        noDisplay = true;
      };

      item = pkgs.makeDesktopItem (desktopItemTemlate // {
        # passthru.providedSessions = [ "stumpwm" ];
        exec = "${stumpwm-mate-script}";
        # destination = "/share/xsessions";
        extraConfig = {
          X-MATE-WMName = "stumpwm";
          X-MATE-Autostart-Phase = "WindowManager";
          X-MATE-Provides = "windowmanager";
          X-MATE-Autostart-Notify = "false";
        };
      });
    in
    { inherit item icons; };

in
{
  disabledModules = [ "services/x11/window-managers/stumpwm.nix" ];
  # NOTE: https://github.com/search?q=xserver.displayManager.session+language%3ANix+&type=code
  options.services.xserver.windowManager.stumpwm = with types; {
    enable = mkEnableOption "StumpWM";
    package = mkOption {
      type = package;
      default = pkgs.stumpwm_release_latest.bin;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      xdg.mime.enable = true;
      programs.gdk-pixbuf.modulePackages = with pkgs; [
        librsvg
        webp-pixbuf-loader
      ];
      services.xserver = {
        xkb.layout = "us";
        enable = true;
        updateDbusEnvironment = true;
        desktopManager.mate.enable = true;
      };

      services.gnome.glib-networking.enable = true;

      environment.sessionVariables.CPATH = "${pkgs.libfixposix}/include";
      # services.displayManager.sessionPackages = [ stumpwm_desktop.item ];
      environment.systemPackages = [
        cfg.package
        pkgs.stumpwm_release_latest.stumpish
        stumpwm_desktop.item
        stumpwm_desktop.icons
      ];
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
            cfgOpenSnitch = config.services ? opensnitch;
            cfgMimeApps = config.xdg.mimeApps.enable;
          in
          {
            options.services.xserver.windowManager.stumpwm.enable = lib.mkEnableOption "Use mate+stumpwm";
            options.services.xserver.windowManager.stumpwm.confDir = with lib.types; lib.mkOption {
              default = null;
              # let tPath = "${self}/users/${name}/dotfiles/stumpwm.d";
              # in if builtins.pathExists tPath then tPath else null;
              type = nullOr (oneOf [ path string ]);
              apply = v: if v != null then builtins.toPath v else null;
              description = "Path to stumpwm config dir";
            };

            config = lib.mkIf cfg.enable (lib.mkMerge [
              {
                dconf.settings = {
                  "org/mate/desktop/background".draw-background = false;
                  "org/mate/desktop/background".show-desktop-icons = false;

                  "org/mate/desktop/session".default-session = [ "mate-settings-daemon" ];
                  "org/mate/desktop/session".required-components-list = [ "windowmanager" "panel" "filemanager" ];
                  "org/mate/desktop/session".gnome-compat-startup = [ "smproxy" ];

                  "org/mate/desktop/session/required-components".windowmanager = "stumpwm";
                  "org/mate/desktop/session/required-components".filemanager = "caja";
                  "org/mate/desktop/session/required-components".panel = "mate-panel";

                  "org/mate/panel/general".object-id-list = [ "menu-bar" "notification-area" "clock" ];
                  "org/mate/panel/general".toplevel-id-list = [ "top" ];

                  "org/mate/panel/objects/menu-bar".object-type = "menu-bar";
                  "org/mate/panel/objects/menu-bar".locked = true;
                  "org/mate/panel/objects/menu-bar".toplevel-id = "top";
                  "org/mate/panel/objects/menu-bar".position = 0;

                  "org/mate/panel/objects/clock".applet-iid = "ClockAppletFactory::ClockApplet";
                  "org/mate/panel/objects/clock".locked = true;
                  "org/mate/panel/objects/clock".object-type = "applet";
                  "org/mate/panel/objects/clock".panel-right-stick = true;
                  "org/mate/panel/objects/clock".position = 0;
                  "org/mate/panel/objects/clock".toplevel-id = "top";

                  "org/mate/panel/objects/notification-area".applet-iid = "NotificationAreaAppletFactory::NotificationArea";
                  "org/mate/panel/objects/notification-area".locked = true;
                  "org/mate/panel/objects/notification-area".object-type = "applet";
                  "org/mate/panel/objects/notification-area".panel-right-stick = true;
                  "org/mate/panel/objects/notification-area".position = 10;
                  "org/mate/panel/objects/notification-area".toplevel-id = "top";

                  "org/mate/panel/toplevels/top".expand = true;
                  "org/mate/panel/toplevels/top".orientation = "top";
                  "org/mate/panel/toplevels/top".screen = 0;
                  "org/mate/panel/toplevels/top".size = 24;

                  "org/mate/caja/preferences".enable-delete = true;
                  "org/mate/caja/preferences".confirm-trash = false;
                  "org/mate/caja/preferences".default-folder-viewer = "list-view";

                  "org/mate/notification-daemon".popup-location = "top_right";
                  "org/mate/notification-daemon".theme = "standard";

                  "ca/desrt/dconf-editor".show-warning = false;
                };
              }

              (lib.mkIf cfgMimeApps {
                xdg.mimeApps.defaultApplications."inode/directory" = "caja-folder-handler.desktop";
                xdg.mimeApps.defaultApplications."application/x-mate-saved-search" = "caja-folder-handler.desktop";
              })

              # (lib.mkIf cfgOpenSnitch {
              #   services.opensnitch.allow =
              #     with builtins;
              #     let
              #       withDir = dir: map (x: "${dir}/${x}") (filter (hasPrefix ".") (attrNames (readDir dir)));
              #     in
              #     flatten (map withDir [
              #       "${pkgs.mate.mate-panel}/libexec"
              #       "${pkgs.gvfs}/libexec"
              #     ]);
              # })

              (lib.mkIf (!builtins.isNull cfg.confDir) {
                xdg.configFile."stumpwm".source = cfg.confDir;
                xdg.configFile."stumpwm".recursive = true;
                xdg.configFile."common-lisp/asdf-output-translations.conf.d/99-disable-cache.conf".text = ":disable-cache";
                xdg.dataFile."fonts".source = fontsDir;
              })

            ]);
          }
        )
      ];
    })

  ];
}
