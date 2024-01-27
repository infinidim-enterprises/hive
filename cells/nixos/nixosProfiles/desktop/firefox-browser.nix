{ inputs, cell, ... }:

{ pkgs, lib, config, ... }:
lib.mkMerge [
  (lib.mkIf (config ? home-manager) {
    home-manager.sharedModules = [
      ({ config, lib, ... }:
        lib.mkIf config.xdg.mimeApps.enable {
          xdg.mimeApps.defaultApplications = {
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
          };
        })
      {
        home.packages = with pkgs; [ buku uget ];
        programs.firefox.enable = true;
        programs.firefox.package = pkgs.firefox-esr-unwrapped;

        programs.firefox.extraPolicies = import ./_firefox-browser-policies.nix;
        programs.firefox.extraPrefs = ''
          // Show more ssl cert infos
          lockPref("security.identityblock.show_extended_validation", true);
          lockPref("extensions.autoDisableScopes", 0)
        '';

        programs.firefox.extensions = with pkgs.firefox-addons; [
          # ether-metamask
          russian-spellchecking-dic-3703.value
          export-tabs-urls-and-titles.value
          # passff
          # org-capture
          # promnesia
          swisscows-search.value

          # aw-watcher-web

          # duckduckgo-for-firefox
          # browserpass-ce
          # ugetintegration
          # bukubrow
          # reduxdevtools
          # absolute-enable-right-click
          # canvasblocker
          # clearurls
          # cookie-autodelete
          # decentraleyes
          # multi-account-containers
          # temporary-containers
          # https-everywhere
          # privacy-badger17
          # ublock-origin
          # umatrix
        ];

        programs.firefox.profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;
          # TODO: firefox: How to set "restore session on startup" in settings?
          settings = {
            "distribution.searchplugins.defaultLocale" = "en-US";

            "general.smoothScroll" = true;
            "general.useragent.locale" = "en-US";

            "browser.tabs.tabMinWidth" = 270;
            "browser.contentblocking.category" = "standard";
            "browser.display.use_system_colors" = true;
            "browser.display.use_document_fonts" = 0;

            "browser.uidensity" = 1;

            "browser.search.region" = "US";
            "intl.accept_languages" = "en-us,en,ru";
            "devtools.editor.keymap" = "emacs";

            #######
            "app.normandy.api_url" = "";
            "app.normandy.enabled" = false;
            "app.shield.optoutstudies.enabled" = false;
            "app.update.auto" = false;
            "beacon.enabled" = false;
            "breakpad.reportURL" = "";
            "browser.aboutConfig.showWarning" = false;
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.cache.disk.enable" = false;
            "browser.cache.offline.enable" = false;
            "browser.cache.memory.capacity" = 100000;
            "browser.crashReports.unsubmittedCheck.autoSubmit" = false;
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            "browser.crashReports.unsubmittedCheck.enabled" = false;
            "browser.disableResetPrompt" = true;
            "browser.fixup.alternate.enabled" = false;
            "browser.newtab.preload" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.enabled" = false;
            "browser.newtabpage.enhanced" = false;
            "browser.newtabpage.introShown" = true;
            "browser.safebrowsing.appRepURL" = "";
            "browser.safebrowsing.blockedURIs.enabled" = false;
            "browser.safebrowsing.downloads.enabled" = false;
            "browser.safebrowsing.downloads.remote.enabled" = false;
            "browser.safebrowsing.downloads.remote.url" = "";
            "browser.safebrowsing.enabled" = false;
            "browser.safebrowsing.malware.enabled" = false;
            "browser.safebrowsing.phishing.enabled" = false;
            "browser.selfsupport.url" = "";
            "browser.send_pings" = false;
            "browser.sessionstore.privacy_level" = 2;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.startup.homepage_override.mstone" = "ignore";
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.urlbar.clickSelectsAll" = true;
            "browser.urlbar.groupLabels.enabled" = false;
            "browser.urlbar.quicksuggest.enabled" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
            "browser.urlbar.trimURLs" = false;
            "browser.urlbar.unitConversion.enabled" = true;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "device.sensors.ambientLight.enabled" = false;
            "device.sensors.enabled" = false;
            "device.sensors.motion.enabled" = false;
            "device.sensors.orientation.enabled" = false;
            "device.sensors.proximity.enabled" = false;
            "dom.battery.enabled" = false;
            "dom.event.clipboardevents.enabled" = false;
            "dom.webaudio.enabled" = false;
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.manifest.uri" = "";
            "experiments.supported" = false;
            "extensions.CanvasBlocker@kkapsner.de.whiteList" = "";
            "extensions.ClearURLs@kevinr.whiteList" = "";
            "extensions.FirefoxMulti-AccountContainers@mozilla.whiteList" = "";
            "extensions.TemporaryContainers@stoically.whiteList" = "";
            "extensions.getAddons.cache.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "extensions.greasemonkey.stats.optedin" = false;
            "extensions.greasemonkey.stats.url" = "";
            "extensions.pocket.enabled" = false;
            "extensions.screenshots.upload-disabled" = true;
            "extensions.shield-recipe-client.api_url" = "";
            "extensions.shield-recipe-client.enabled" = false;
            "extensions.webservice.discoverURL" = "";
            "media.autoplay.default" = 1;
            "media.autoplay.enabled" = false;
            "media.eme.enabled" = false;
            "media.gmp-widevinecdm.enabled" = false;
            "media.navigator.enabled" = false;
            "media.peerconnection.enabled" = false;
            "media.video_stats.enabled" = false;
            "network.allow-experiments" = false;
            "network.captive-portal-service.enabled" = false;
            "network.cookie.cookieBehavior" = 1;
            "network.dns.disablePrefetch" = true;
            "network.dns.disablePrefetchFromHTTPS" = true;
            "network.http.referer.spoofSource" = true;
            "network.http.speculative-parallel-limit" = 0;
            "network.predictor.enable-prefetch" = false;
            "network.predictor.enabled" = false;
            "network.prefetch-next" = false;
            "network.trr.mode" = 5;
            "privacy.donottrackheader.enabled" = true;
            "privacy.donottrackheader" = 1;
            "privacy.trackingprotection.cryptomining.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "privacy.trackingprotection.pbmode.enabled" = true;
            "privacy.usercontext.about_newtab_segregation.enabled" = true;
            "security.ssl.disable_session_identifiers" = true;
            "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSite" = false;
            "signon.autofillForms" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.cachedClientID" = "";
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.prompted" = 2;
            "toolkit.telemetry.rejected" = true;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.unifiedIsOptIn" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "webgl.disabled" = true;
            "webgl.renderer-string-override" = " ";
            "webgl.vendor-string-override" = " ";
          };
        };
      }
    ];
  })
]
