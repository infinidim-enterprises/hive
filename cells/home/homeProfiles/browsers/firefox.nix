{ inputs, cell, ... }:

{ pkgs, lib, config, name, osConfig, ... }:
let
  search = {
    force = true;
    default = "Swisscows";
    order = [ "Swisscows" ];
    engines = {
      "Amazon.com".metaData.hidden = true;
      "Bing".metaData.hidden = true;
      "Google".metaData.hidden = true;
      "Wikipedia (en)".metaData.alias = "@w";
      # "swisscows" = { urls = [{ template = "https://swisscows.com/en/web?query={searchTerms}&region=en-US"; }]; };

      "Nix Packages" = {
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "channel";
                value = "unstable";
              }
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@np" ];
      };

      "NixOS Options" = {
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "channel";
                value = "unstable";
              }
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@no" ];
      };

      "NixOS Wiki" = {
        urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
        iconUpdateURL = "https://nixos.wiki/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@nw" ];
      };

      "nix functions" = {
        urls = [{ template = "https://noogle.dev/q?term={searchTerms}"; }];
        definedAliases = [ "@nf" ];
      };

      "mynixos" = {
        urls = [{ template = "https://mynixos.com/search?q={searchTerms}"; }];
        definedAliases = [ "@mn" ];
      };

      "home-manager options" = {
        urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }];
        definedAliases = [ "@ho" ];
      };
    };
  };

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
  settings = arkenfox_user_js // (import ./_firefox-browser-settings.nix) // {
    "services.sync.username" = "${name}@${osConfig.networking.domain}";
    "services.sync.autoconnect" = true;
  };
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
      # FIXME: firefox_decrypt # extract passwords from profiles TODO: make an overlay with git version.
    ];

    programs.firefox.profiles.default = {
      inherit settings search;
      id = 0;
      name = "default";
      isDefault = true;

      userChrome = ''
        /* Hide horizontal tabs on top of the window */
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
          height: 0 !important;
          margin-bottom: 0 !important;
        }
      '';

      # NOTE: https://bugzilla.mozilla.org/show_bug.cgi?id=259356
      # NOTE: fuck you mozilla devs, you're a bunch of stupid wankers! - a 20 years old bug
      extensions = with pkgs.firefox-addons; [
        # ublock-origin
        # skip-redirect
        # privacy-badger17
        # umatrix

        multi-account-containers

        istilldontcareaboutcookies
        # MAYBE: privacy-redirect
        tree-style-tab
        auto-tab-discard
        # temporary-containers

        # ether-metamask
        ugetintegration
        bukubrow
        russian-spellchecking-dic-3703
        export-tabs-urls-and-titles
        swisscows-search
        darkreader

        absolute-enable-right-click
        # aw-watcher-web
        # NOTE: makes everything very slow - decentraleyes

        # passff
        # org-capture
        # promnesia
        # duckduckgo-for-firefox
        # browserpass-ce
        # reduxdevtools
        # canvasblocker
        # clearurls
        # cookie-autodelete
        # https-everywhere
        #
      ];
    };
  }
]
