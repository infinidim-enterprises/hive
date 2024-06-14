# NOTE: https://addons.mozilla.org/en-US/firefox/addon/enterprise-policy-generator/
#       https://ffprofile.com
{
  EnableFirefoxSync = true;
  OverrideFirstRunPage = "about:preferences#sync";
  CaptivePortal = false;
  NetworkPrediction = false;
  DNSOverHTTPS.Enabled = false;
  DisableAppUpdate = true;
  DisableFirefoxScreenshots = true;
  DisableFirefoxStudies = true;
  DisableFirefoxAccounts = true;
  DisableTelemetry = true;
  DisablePocket = true;
  DisableFeedbackCommands = true;
  DisableProfileImport = true;
  DisableProfileRefresh = true;
  DisableSafeMode = true;
  DisableSetDesktopBackground = true;
  DisableSystemAddonUpdate = true;
  FirefoxHome.Pocket = false;
  FirefoxHome.Snippets = false;
  UserMessaging.ExtensionRecommendations = false;
  UserMessaging.SkipOnboarding = true;
  DontCheckDefaultBrowser = true;

  EnableTrackingProtection = {
    Cryptomining = true;
    Fingerprinting = true;
    Value = true;
  };

  ExtensionUpdate = false;
  NewTabPage = false;
  NoDefaultBookmarks = true;
  OverrideFirstRunPage = "";
  OverridePostUpdatePage = "";
  PopupBlocking = { Default = true; };

  Preferences = {
    "browser.cache.disk.enable" = false;
    "browser.search.update" = true;
    "browser.tabs.warnOnClose" = false;
    "browser.urlbar.suggest.bookmark" = true;
    "browser.urlbar.suggest.history" = true;
    "browser.urlbar.suggest.openpage" = true;
    "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
    "dom.disable_window_flip" = true;
    "dom.disable_window_move_resize" = true;
    "dom.event.contextmenu.enabled" = true;
    "extensions.getAddons.showPane" = false;
    "media.gmp-gmpopenh264.enabled" = true;
    "media.gmp-widevinecdm.enabled" = true;
    "places.history.enabled" = true;
    "security.ssl.errorReporting.enabled" = false;
  };

  SearchBar = "unified";
  SearchEngines = {
    Default = "DuckDuckGo";
    DefaultPrivate = "DuckDuckGo";
    PreventInstalls = false;
  };

  SearchSuggestEnabled = true;
}
