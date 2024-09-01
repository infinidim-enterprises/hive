{ inputs, cell, ... }:

{ pkgs, lib, config, name, osConfig, ... }:
let
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

    /* Autohide nav-bar */
    #nav-bar {
      visibility: collapse;
      opacity: 0;
      transition: opacity 0.3s ease;
    }

    #nav-bar:hover {
      visibility: visible;
      opacity: 1;
    }
  '';

  # NOTE: https://bugzilla.mozilla.org/show_bug.cgi?id=259356
  # NOTE: fuck you mozilla devs, you're a bunch of stupid wankers! - a 20 years old bug

  common_extension = with pkgs.firefox-addons; [
    russian-spellchecking-dic-3703
    absolute-enable-right-click
    export-tabs-urls-and-titles
    istilldontcareaboutcookies
    auto-tab-discard
    swisscows-search
    ugetintegration
    tree-style-tab
    darkreader
    bukubrow

    # ublock-origin
    # skip-redirect
    # privacy-badger17
    # umatrix
    # MAYBE: privacy-redirect
    # temporary-containers
    # ether-metamask
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

  ];

  flaky_extensions = with pkgs.firefox-addons; [
    multi-account-containers
  ];

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

    programs.firefox.profiles.default =
      {
        inherit settings search userChrome;
        id = 0;
        name = "default";
        isDefault = true;
        extensions = common_extension;
      };

    programs.firefox.profiles.containers = {
      inherit settings search userChrome;
      id = 1;
      name = "containers";
      isDefault = false;
      extensions = common_extension ++ flaky_extensions;
    };
  }
]
