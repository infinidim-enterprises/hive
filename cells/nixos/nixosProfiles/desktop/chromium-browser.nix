{ inputs, cell, ... }:

{ lib, config, pkgs, ... }:

lib.mkMerge [
  {
    environment.systemPackages = [ pkgs.chromium ];

    programs.chromium.enable = true; # # NOTE: chromium policies only!
    programs.chromium.defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    # programs.chromium.defaultSearchProviderSuggestURL = "";

    programs.chromium.extensions = [
      # "nglaklhklhcoonedhgnpgddginnjdadi" # TODO: mkIf hmModule activitywatch enabled.
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # metamask
      "kcgpggonjhmeaejebeoeomdlohicfhce" # Removes cookies for the current site
      # "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      # "maekfnoeejhpjfkfmdlckioggdcdofpg" # Adblocker for Youtube™
      "bgnkhhnnamicmpeenaelnjfhikgbkllg" # AdGuard AdBlocker
      "jappgmhllahigjolfpgbjdfhciabdnde" # Link Map - Professional Tab Manager
      "edacconmaakjimmfgnblocblbcdcpbko" # session-buddy
      # "jpefmbpcbebpjpmelobfakahfdcgcmkl" # adblock for youtube
      # "kbbdabhdfibnancpjfhlkhafgdilcnji" # Screenity
      # "kkkjlfejijcjgjllecmnejhogpbcigdc" # org-capture
      # "kdmegllpofldcpaclldkopnnjjljoiio" # promnesia
      # "bjfhmglciegochdpefhhlphglcehbmek" # hypothes.is - web annotation
      # "liecbddmkiiihnedobmlmillhodjkdmb" # https://www.loom.com
      # "lpfemeioodjbpieminkklglpmhlngfcn" # WebChatGPT: ChatGPT with internet access
      ### NOTE: Another org-capture thing, without much deps https://github.com/karlicoss/grasp
      # "ohhbcfjmnbmgkajljopdjcaokbpgbgfa"
      ###
      # "ellkdbaphhldpeajbepobaecooaoafpg" # fetchai-network-wallet
    ];
    # ++ (lib.mkIf false [ "nglaklhklhcoonedhgnpgddginnjdadi" ]);

    # NOTE: https://chromeenterprise.google/policies/
    programs.chromium.extraOpts = {
      DefaultSearchProviderEnabled = true;
      RestoreOnStartup = 1;

      # HomepageLocation = "https://www.chromium.org";
      # NewTabPageLocation = "https://www.chromium.org";

      browser.has_seen_welcome_page = true;

      spellcheck.dictionaries = [ "en-US" "ru-RU" "de-DE" ];
      spellcheck.dictionary = "en-US";

      extensions.theme.use_system = true;
      extensions.theme.id = "";

      # webkit.webprefs.default_fixed_font_size = 16;
      # webkit.webprefs.default_font_size = 16;
      # webkit.webprefs.minimum_font_size = 16;

      webkit.webprefs.fonts = {
        fixed.Zyyy = "UbuntuMono Nerd Font";
        sansserif.Zyyy = "UbuntuMono Nerd Font";
        serif.Zyyy = "UbuntuMono Nerd Font";
        standard.Zyyy = "UbuntuMono Nerd Font";
      };

    };
    #  /etc/chromium/master_preferences
  }

  # (lib.mkIf (config ? home-manager) {
  #   home-manager.sharedModules = [
  #     { programs.chromium.enable = true; }
  #     ({ config, lib, ... }:
  #       lib.mkIf (config.services ? opensnitch)
  #         { services.opensnitch.allow = [ "${config.programs.chromium.package.browser}/libexec/chromium/chromium" ]; })
  #   ];
  # })
]
