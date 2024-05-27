{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:
let
  arkenfox_user_js =
    let
      inherit (lib // builtins) fromJSON fileContents;
      jsonFile =
        pkgs.runCommandNoCC "arkenfox_user_js" { buildInputs = [ pkgs.nodejs ]; } ''
          cp ${./user_js_to_json.js} ./script.js
          cp ${pkgs.sources.firefox_user_js.src}/user.js ./
          node ./script.js
          cp prefs.json $out
        '';
    in
    fromJSON (fileContents jsonFile);
  # NOTE: Not letting arkenfox overwrite settings
  settings = arkenfox_user_js // (import ./_firefox-browser-settings.nix);
  policies = import ./_firefox-browser-policies.nix;
in
lib.mkMerge [
  (lib.mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  })

  {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      inherit policies;
    };
  }

  {
    home.packages = with pkgs; [
      buku # Private cmdline bookmark manager
      uget # Download manager using GTK and libcurl
      firefox_decrypt # extract passwords from profiles TODO: make an overlay with git version.
    ];

    programs.firefox.profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      extraConfig = ''
        lockPref("security.identityblock.show_extended_validation", true);
        lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
        lockPref("browser.tabs.inTitlebar", "0");
        lockPref("media.ffmpeg.vaapi.enabled", true);
      '';

      userChrome = ''
        /* Hide horizontal tabs on top of the window */
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
        }
      '';

      # TODO: firefox: How to set "restore session on startup" in settings?
      inherit settings;

      # NOTE: https://bugzilla.mozilla.org/show_bug.cgi?id=259356
      # NOTE: fuck you mozilla devs, you're a bunch of stupid wankers! - a 20 years old bug
      extensions = with pkgs.firefox-addons; [
        ublock-origin
        skip-redirect
        multi-account-containers

        istilldontcareaboutcookies
        # MAYBE: privacy-redirect
        tree-style-tab
        auto-tab-discard
        temporary-containers

        # ether-metamask
        ugetintegration
        russian-spellchecking-dic-3703
        export-tabs-urls-and-titles
        swisscows-search
        darkreader
        privacy-badger17
        absolute-enable-right-click
        # aw-watcher-web

        # passff
        # org-capture
        # promnesia
        # duckduckgo-for-firefox
        # browserpass-ce
        # bukubrow
        # reduxdevtools
        # canvasblocker
        # clearurls
        # cookie-autodelete
        # decentraleyes
        # https-everywhere
        # umatrix
      ];
    };
  }
]
