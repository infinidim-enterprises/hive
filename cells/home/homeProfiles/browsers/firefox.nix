{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:
let
  settings = import ./_firefox-browser-settings.nix;
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
        // Show more ssl cert infos
        lockPref("security.identityblock.show_extended_validation", true);
      '';
      # TODO: firefox: How to set "restore session on startup" in settings?
      inherit settings;

      # NOTE: https://bugzilla.mozilla.org/show_bug.cgi?id=259356
      # NOTE: fuck you mozilla devs, you're a bunch of stupid wankers! - a 20 years old bug
      extensions = with pkgs.firefox-addons; [
        # ether-metamask
        ugetintegration
        russian-spellchecking-dic-3703
        export-tabs-urls-and-titles
        # passff
        # org-capture
        # promnesia
        swisscows-search
        darkreader
        privacy-badger17
        absolute-enable-right-click
        aw-watcher-web

        # duckduckgo-for-firefox
        # browserpass-ce
        # bukubrow
        # reduxdevtools

        # canvasblocker
        # clearurls
        # cookie-autodelete
        # decentraleyes
        # multi-account-containers
        # temporary-containers
        # https-everywhere
        # ublock-origin
        # umatrix
      ];
    };
  }
]
