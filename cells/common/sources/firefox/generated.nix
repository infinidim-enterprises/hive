{ lib, ... }:
{
  "absolute-enable-right-click" = rec {
    pname = "absolute-enable-right-click";
    version = "1.3.8";
    addonId = "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}";
    url = "https://addons.mozilla.org/firefox/downloads/file/1205179/absolute_enable_right_click-1.3.8.xpi";
    sha256 = "d1ca76d23234e6fd0f5d521caef62d20d071c8806887cda89914fd8325715a0a";
    meta = with lib; {
      description = "Force Enable Right Click &amp; Copy";
      license = licenses.bsd2;
      mozPermissions = ["tabs" "storage" "activeTab" "<all_urls>"];
      platforms = platforms.all;
    };
  };
  "aw-watcher-web" = rec {
    pname = "aw-watcher-web";
    version = "0.4.8";
    addonId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4114360/aw_watcher_web-0.4.8.xpi";
    sha256 = "6be85d9755013520a5a4835cb8ae2a3287e4cb9c12b5baf4957ab10368dd45d2";
    meta = with lib; {
      homepage = "https://github.com/ActivityWatch/aw-watcher-web";
      description = "This extension logs the current tab and your browser activity to ActivityWatch.";
      license = licenses.mpl20;
      mozPermissions = [
        "tabs"
        "alarms"
        "notifications"
        "activeTab"
        "storage"
        "http://localhost:5600/api/*"
        "http://localhost:5666/api/*"
      ];
      platforms = platforms.all;
    };
  };
  "browserpass-ce" = rec {
    pname = "browserpass-ce";
    version = "3.8.0";
    addonId = "browserpass@maximbaz.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4187654/browserpass_ce-3.8.0.xpi";
    sha256 = "5291d94443be41a80919605b0939c16cc62f9100a8b27df713b735856140a9a7";
    meta = with lib; {
      homepage = "https://github.com/browserpass/browserpass-extension";
      description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fcd8dcb23434c51a78197a1c25d3e2277aa1bc764c827b4b4726ec5a5657eb64/http%3A//passwordstore.org\" rel=\"nofollow\">passwordstore.org</a>) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
      license = licenses.isc;
      mozPermissions = [
        "activeTab"
        "alarms"
        "tabs"
        "clipboardRead"
        "clipboardWrite"
        "nativeMessaging"
        "notifications"
        "webRequest"
        "webRequestBlocking"
        "http://*/*"
        "https://*/*"
      ];
      platforms = platforms.all;
    };
  };
  "bukubrow" = rec {
    pname = "bukubrow";
    version = "5.0.3.0";
    addonId = "bukubrow@samhh.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3769984/bukubrow-5.0.3.0.xpi";
    sha256 = "4c9424d0f13df8f1f6ac605302c42bb30f3c138eb76c8d4ced5d45a637942913";
    meta = with lib; {
      homepage = "https://github.com/samhh/bukubrow";
      description = "Synchronise your browser bookmarks with Buku";
      license = licenses.gpl3;
      mozPermissions = [
        "nativeMessaging"
        "storage"
        "tabs"
        "contextMenus"
        "activeTab"
      ];
      platforms = platforms.all;
    };
  };
  "canvasblocker" = rec {
    pname = "canvasblocker";
    version = "1.9";
    addonId = "CanvasBlocker@kkapsner.de";
    url = "https://addons.mozilla.org/firefox/downloads/file/4097901/canvasblocker-1.9.xpi";
    sha256 = "5248c2c2dedd14b8aa2cd73f9484285d9453e93339f64fcf04a3d63c859cf3d7";
    meta = with lib; {
      homepage = "https://github.com/kkapsner/CanvasBlocker/";
      description = "Alters some JS APIs to prevent fingerprinting.";
      license = licenses.mpl20;
      mozPermissions = [
        "<all_urls>"
        "storage"
        "tabs"
        "webRequest"
        "webRequestBlocking"
        "contextualIdentities"
        "cookies"
        "privacy"
      ];
      platforms = platforms.all;
    };
  };
  "clearurls" = rec {
    pname = "clearurls";
    version = "1.26.1";
    addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4064884/clearurls-1.26.1.xpi";
    sha256 = "e20168d63cb1b8ba3ad0de4cdb42c540d99fe00aa9679b59f49bccc36f106291";
    meta = with lib; {
      homepage = "https://clearurls.xyz/";
      description = "Removes tracking elements from URLs";
      license = licenses.lgpl3;
      mozPermissions = [
        "<all_urls>"
        "webRequest"
        "webRequestBlocking"
        "storage"
        "unlimitedStorage"
        "contextMenus"
        "webNavigation"
        "tabs"
        "downloads"
        "*://*.google.com/*"
        "*://*.google.ad/*"
        "*://*.google.ae/*"
        "*://*.google.com.af/*"
        "*://*.google.com.ag/*"
        "*://*.google.com.ai/*"
        "*://*.google.al/*"
        "*://*.google.am/*"
        "*://*.google.co.ao/*"
        "*://*.google.com.ar/*"
        "*://*.google.as/*"
        "*://*.google.at/*"
        "*://*.google.com.au/*"
        "*://*.google.az/*"
        "*://*.google.ba/*"
        "*://*.google.com.bd/*"
        "*://*.google.be/*"
        "*://*.google.bf/*"
        "*://*.google.bg/*"
        "*://*.google.com.bh/*"
        "*://*.google.bi/*"
        "*://*.google.bj/*"
        "*://*.google.com.bn/*"
        "*://*.google.com.bo/*"
        "*://*.google.com.br/*"
        "*://*.google.bs/*"
        "*://*.google.bt/*"
        "*://*.google.co.bw/*"
        "*://*.google.by/*"
        "*://*.google.com.bz/*"
        "*://*.google.ca/*"
        "*://*.google.cd/*"
        "*://*.google.cf/*"
        "*://*.google.cg/*"
        "*://*.google.ch/*"
        "*://*.google.ci/*"
        "*://*.google.co.ck/*"
        "*://*.google.cl/*"
        "*://*.google.cm/*"
        "*://*.google.cn/*"
        "*://*.google.com.co/*"
        "*://*.google.co.cr/*"
        "*://*.google.com.cu/*"
        "*://*.google.cv/*"
        "*://*.google.com.cy/*"
        "*://*.google.cz/*"
        "*://*.google.de/*"
        "*://*.google.dj/*"
        "*://*.google.dk/*"
        "*://*.google.dm/*"
        "*://*.google.com.do/*"
        "*://*.google.dz/*"
        "*://*.google.com.ec/*"
        "*://*.google.ee/*"
        "*://*.google.com.eg/*"
        "*://*.google.es/*"
        "*://*.google.com.et/*"
        "*://*.google.fi/*"
        "*://*.google.com.fj/*"
        "*://*.google.fm/*"
        "*://*.google.fr/*"
        "*://*.google.ga/*"
        "*://*.google.ge/*"
        "*://*.google.gg/*"
        "*://*.google.com.gh/*"
        "*://*.google.com.gi/*"
        "*://*.google.gl/*"
        "*://*.google.gm/*"
        "*://*.google.gp/*"
        "*://*.google.gr/*"
        "*://*.google.com.gt/*"
        "*://*.google.gy/*"
        "*://*.google.com.hk/*"
        "*://*.google.hn/*"
        "*://*.google.hr/*"
        "*://*.google.ht/*"
        "*://*.google.hu/*"
        "*://*.google.co.id/*"
        "*://*.google.ie/*"
        "*://*.google.co.il/*"
        "*://*.google.im/*"
        "*://*.google.co.in/*"
        "*://*.google.iq/*"
        "*://*.google.is/*"
        "*://*.google.it/*"
        "*://*.google.je/*"
        "*://*.google.com.jm/*"
        "*://*.google.jo/*"
        "*://*.google.co.jp/*"
        "*://*.google.co.ke/*"
        "*://*.google.com.kh/*"
        "*://*.google.ki/*"
        "*://*.google.kg/*"
        "*://*.google.co.kr/*"
        "*://*.google.com.kw/*"
        "*://*.google.kz/*"
        "*://*.google.la/*"
        "*://*.google.com.lb/*"
        "*://*.google.li/*"
        "*://*.google.lk/*"
        "*://*.google.co.ls/*"
        "*://*.google.lt/*"
        "*://*.google.lu/*"
        "*://*.google.lv/*"
        "*://*.google.com.ly/*"
        "*://*.google.co.ma/*"
        "*://*.google.md/*"
        "*://*.google.me/*"
        "*://*.google.mg/*"
        "*://*.google.mk/*"
        "*://*.google.ml/*"
        "*://*.google.com.mm/*"
        "*://*.google.mn/*"
        "*://*.google.ms/*"
        "*://*.google.com.mt/*"
        "*://*.google.mu/*"
        "*://*.google.mv/*"
        "*://*.google.mw/*"
        "*://*.google.com.mx/*"
        "*://*.google.com.my/*"
        "*://*.google.co.mz/*"
        "*://*.google.com.na/*"
        "*://*.google.com.nf/*"
        "*://*.google.com.ng/*"
        "*://*.google.com.ni/*"
        "*://*.google.ne/*"
        "*://*.google.nl/*"
        "*://*.google.no/*"
        "*://*.google.com.np/*"
        "*://*.google.nr/*"
        "*://*.google.nu/*"
        "*://*.google.co.nz/*"
        "*://*.google.com.om/*"
        "*://*.google.com.pa/*"
        "*://*.google.com.pe/*"
        "*://*.google.com.pg/*"
        "*://*.google.com.ph/*"
        "*://*.google.com.pk/*"
        "*://*.google.pl/*"
        "*://*.google.pn/*"
        "*://*.google.com.pr/*"
        "*://*.google.ps/*"
        "*://*.google.pt/*"
        "*://*.google.com.py/*"
        "*://*.google.com.qa/*"
        "*://*.google.ro/*"
        "*://*.google.ru/*"
        "*://*.google.rw/*"
        "*://*.google.com.sa/*"
        "*://*.google.com.sb/*"
        "*://*.google.sc/*"
        "*://*.google.se/*"
        "*://*.google.com.sg/*"
        "*://*.google.sh/*"
        "*://*.google.si/*"
        "*://*.google.sk/*"
        "*://*.google.com.sl/*"
        "*://*.google.sn/*"
        "*://*.google.so/*"
        "*://*.google.sm/*"
        "*://*.google.sr/*"
        "*://*.google.st/*"
        "*://*.google.com.sv/*"
        "*://*.google.td/*"
        "*://*.google.tg/*"
        "*://*.google.co.th/*"
        "*://*.google.com.tj/*"
        "*://*.google.tk/*"
        "*://*.google.tl/*"
        "*://*.google.tm/*"
        "*://*.google.tn/*"
        "*://*.google.to/*"
        "*://*.google.com.tr/*"
        "*://*.google.tt/*"
        "*://*.google.com.tw/*"
        "*://*.google.co.tz/*"
        "*://*.google.com.ua/*"
        "*://*.google.co.ug/*"
        "*://*.google.co.uk/*"
        "*://*.google.com.uy/*"
        "*://*.google.co.uz/*"
        "*://*.google.com.vc/*"
        "*://*.google.co.ve/*"
        "*://*.google.vg/*"
        "*://*.google.co.vi/*"
        "*://*.google.com.vn/*"
        "*://*.google.vu/*"
        "*://*.google.ws/*"
        "*://*.google.rs/*"
        "*://*.google.co.za/*"
        "*://*.google.co.zm/*"
        "*://*.google.co.zw/*"
        "*://*.google.cat/*"
        "*://*.yandex.ru/*"
        "*://*.yandex.com/*"
        "*://*.ya.ru/*"
      ];
      platforms = platforms.all;
    };
  };
  "cookie-autodelete" = rec {
    pname = "cookie-autodelete";
    version = "3.8.2";
    addonId = "CookieAutoDelete@kennydo.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4040738/cookie_autodelete-3.8.2.xpi";
    sha256 = "b02438aa5df2a79eb743da1b629b80d8c48114c9d030abb5538b591754e30f74";
    meta = with lib; {
      homepage = "https://github.com/Cookie-AutoDelete/Cookie-AutoDelete";
      description = "Control your cookies! This WebExtension is inspired by Self Destructing Cookies. When a tab closes, any cookies not being used are automatically deleted. Keep the ones you trust (forever/until restart) while deleting the rest. Containers Supported";
      license = licenses.mit;
      mozPermissions = [
        "activeTab"
        "alarms"
        "browsingData"
        "contextMenus"
        "contextualIdentities"
        "cookies"
        "notifications"
        "storage"
        "tabs"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "decentraleyes" = rec {
    pname = "decentraleyes";
    version = "2.0.18";
    addonId = "jid1-BoFifL9Vbdl2zQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4158232/decentraleyes-2.0.18.xpi";
    sha256 = "f8f031ef91c02a1cb1a6552acd02b8f488693400656b4047d68f03ba0a1078d9";
    meta = with lib; {
      homepage = "https://decentraleyes.org";
      description = "Protects you against tracking through \"free\", centralized, content delivery. It prevents a lot of requests from reaching networks like Google Hosted Libraries, and serves local files to keep sites from breaking. Complements regular content blockers.";
      license = licenses.mpl20;
      mozPermissions = [
        "*://*/*"
        "privacy"
        "storage"
        "unlimitedStorage"
        "tabs"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
      ];
      platforms = platforms.all;
    };
  };
  "deepl-translate" = rec {
    pname = "deepl-translate";
    version = "1.5.7";
    addonId = "firefox-extension@deepl.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4167982/deepl_translate-1.5.7.xpi";
    sha256 = "29f51a681bab962d936357d77bb0bdd0b4c57cd7c1f54e8bdc096d913e4b2d80";
    meta = with lib; {
      homepage = "https://deepl.com";
      description = "Translate while you read and write with DeepL Translate, the world’s most accurate translator.";
      mozPermissions = [
        "activeTab"
        "storage"
        "contextMenus"
        "tabs"
        "scripting"
        "identity"
        "webRequest"
        "webRequestBlocking"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "duckduckgo-for-firefox" = rec {
    pname = "duckduckgo-for-firefox";
    version = "2023.11.17";
    addonId = "jid1-ZAdIEUB7XOzOJw@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4197393/duckduckgo_for_firefox-2023.11.17.xpi";
    sha256 = "5f1ea7664f9da66326151aab5ce8a4504f376666bf41fa56b3cb80dd83421d64";
    meta = with lib; {
      homepage = "https://duckduckgo.com/app";
      description = "Simple and seamless privacy protection for your browser: tracker blocking, cookie protection, DuckDuckGo private search, email protection, HTTPS upgrading, and much more.";
      mozPermissions = [
        "contextMenus"
        "webRequest"
        "webRequestBlocking"
        "*://*/*"
        "webNavigation"
        "activeTab"
        "tabs"
        "storage"
        "<all_urls>"
        "alarms"
      ];
      platforms = platforms.all;
    };
  };
  "enterprise-policy-generator" = rec {
    pname = "enterprise-policy-generator";
    version = "5.1.0";
    addonId = "enterprise-policy-generator@agenedia.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3515849/enterprise_policy_generator-5.1.0.xpi";
    sha256 = "84eaf6e2f318619b5c76b5e65b3be0d4006b16323ddf7870417b0100674e2659";
    meta = with lib; {
      homepage = "https://www.soeren-hentzschel.at/firefox-webextensions/enterprise-policy-generator/";
      description = "The Enterprise Policy Engine allows administrators to configure Firefox via a configuration file. The Enterprise Policy Generator helps to create the configuration file.";
      license = licenses.mpl20;
      mozPermissions = ["menus" "storage"];
      platforms = platforms.all;
    };
  };
  "ether-metamask" = rec {
    pname = "ether-metamask";
    version = "11.5.1";
    addonId = "webextension@metamask.io";
    url = "https://addons.mozilla.org/firefox/downloads/file/4198260/ether_metamask-11.5.1.xpi";
    sha256 = "9b21dba9e3956c30c8a2cf2e22b068d6c2aea5a62142e9969e02ded790d3e97e";
    meta = with lib; {
      description = "Ethereum Browser Extension";
      mozPermissions = [
        "storage"
        "unlimitedStorage"
        "clipboardWrite"
        "http://localhost:8545/"
        "https://*.infura.io/"
        "https://*.codefi.network/"
        "https://chainid.network/chains.json"
        "https://lattice.gridplus.io/*"
        "activeTab"
        "webRequest"
        "*://*.eth/"
        "notifications"
        "file://*/*"
        "http://*/*"
        "https://*/*"
        "*://connect.trezor.io/*/popup.html"
      ];
      platforms = platforms.all;
    };
  };
  "export-tabs-urls-and-titles" = rec {
    pname = "export-tabs-urls-and-titles";
    version = "0.2.12";
    addonId = "{17165bd9-9b71-4323-99a5-3d4ce49f3d75}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3398882/export_tabs_urls_and_titles-0.2.12.xpi";
    sha256 = "ff71ff6e300bf00e02ba79e127073f918aec79f951b749b2f06add006e773ac9";
    meta = with lib; {
      homepage = "https://github.com/alct/export-tabs-urls";
      description = "List the URLs of all the open tabs and copy that list to clipboard or export it to a file.\n\nFeatures:\n- include titles\n- custom format (e.g. markdown, html…)\n- filter tabs\n- limit to current window\n- list non-HTTP(s) URLs\n- ignore pinned tabs";
      license = licenses.gpl3;
      mozPermissions = ["clipboardWrite" "notifications" "storage" "tabs"];
      platforms = platforms.all;
    };
  };
  "grasp" = rec {
    pname = "grasp";
    version = "0.7.1";
    addonId = "{37e42980-a7c9-473c-96d5-13f18e0efc74}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4049682/grasp-0.7.1.xpi";
    sha256 = "a1cbebda55072e2c98242387d86fc51e9c9a9e9b7e72cac23be4757556acc370";
    meta = with lib; {
      homepage = "https://github.com/karlicoss/grasp";
      description = "A reliable way of capturing and tagging web pages and content";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "notifications"
        "activeTab"
        "scripting"
        "http://localhost/capture"
        "https://localhost/capture"
      ];
      platforms = platforms.all;
    };
  };
  "languagetool" = rec {
    pname = "languagetool";
    version = "8.3.0";
    addonId = "languagetool-webextension@languagetool.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4199245/languagetool-8.3.0.xpi";
    sha256 = "e357424e3df9dde4ba10eb9f8f3719ac4830681570557f4d51db15a462cd7667";
    meta = with lib; {
      homepage = "https://languagetool.org";
      description = "With this extension you can check text with the free style and grammar checker LanguageTool. It finds many errors that a simple spell checker cannot detect, like mixing up there/their, a/an, or repeating a word.";
      mozPermissions = [
        "activeTab"
        "storage"
        "contextMenus"
        "alarms"
        "http://*/*"
        "https://*/*"
        "file:///*"
        "*://docs.google.com/document/*"
        "*://languagetool.org/*"
      ];
      platforms = platforms.all;
    };
  };
  "multi-account-containers" = rec {
    pname = "multi-account-containers";
    version = "8.1.3";
    addonId = "@testpilot-containers";
    url = "https://addons.mozilla.org/firefox/downloads/file/4186050/multi_account_containers-8.1.3.xpi";
    sha256 = "33edd98d0fc7d47fa310f214f897ce4dfe268b0f868c9d7f32b4ca50573df85c";
    meta = with lib; {
      homepage = "https://github.com/mozilla/multi-account-containers/#readme";
      description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs. Cookies are separated by container, allowing you to use the web with multiple accounts and integrate Mozilla VPN for an extra layer of privacy.";
      license = licenses.mpl20;
      mozPermissions = [
        "<all_urls>"
        "activeTab"
        "cookies"
        "contextMenus"
        "contextualIdentities"
        "history"
        "idle"
        "management"
        "storage"
        "unlimitedStorage"
        "tabs"
        "webRequestBlocking"
        "webRequest"
      ];
      platforms = platforms.all;
    };
  };
  "org-capture" = rec {
    pname = "org-capture";
    version = "0.2.1";
    addonId = "{ddefd400-12ea-4264-8166-481f23abaa87}";
    url = "https://addons.mozilla.org/firefox/downloads/file/1127481/org_capture-0.2.1.xpi";
    sha256 = "5683ee1ebfafc24abc2d759c7180c4e839c24fa90764d8cf3285c5d72fc81f0a";
    meta = with lib; {
      homepage = "https://github.com/sprig/org-capture-extension";
      description = "A helper for capturing things via org-protocol in emacs: First, set up: <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/04ad17418f8d35ee0f3edf4599aed951b2a5ef88d4bc7e0e3237f6d86135e4fb/http%3A//orgmode.org/worg/org-contrib/org-protocol.html\">http://orgmode.org/worg/org-contrib/org-protocol.html</a> or <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fb401af8127ccf82bc948b0a7af0543eec48d58100c0c46404f81aabeda442e6/https%3A//github.com/sprig/org-capture-extension\">https://github.com/sprig/org-capture-extension</a>\n\nSee <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/6aad51cc4e2f9476f9fff344e6554eade08347181aed05f8b61cda05073daecb/https%3A//youtu.be/zKDHto-4wsU\">https://youtu.be/zKDHto-4wsU</a> for example usage";
      license = licenses.mit;
      mozPermissions = ["activeTab" "storage"];
      platforms = platforms.all;
    };
  };
  "passff" = rec {
    pname = "passff";
    version = "1.16";
    addonId = "passff@invicem.pro";
    url = "https://addons.mozilla.org/firefox/downloads/file/4202971/passff-1.16.xpi";
    sha256 = "ac410a2fbdaa3a43ae3f0ec01056bc0b037b4441a9e38d2cc330f186c8fce112";
    meta = with lib; {
      homepage = "https://github.com/passff/passff";
      description = "Add-on that allows users of the unix password manager 'pass' (see <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/24f646fb865abe6edf9e3f626db62565bfdc2e7819ab33a5b4c30a9573787988/https%3A//www.passwordstore.org/\" rel=\"nofollow\">https://www.passwordstore.org/</a>) to access their password store from Firefox";
      license = licenses.gpl2;
      mozPermissions = [
        "<all_urls>"
        "tabs"
        "storage"
        "nativeMessaging"
        "clipboardWrite"
        "contextMenus"
        "webRequest"
        "webRequestBlocking"
      ];
      platforms = platforms.all;
    };
  };
  "privacy-badger17" = rec {
    pname = "privacy-badger17";
    version = "2023.10.31";
    addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4188670/privacy_badger17-2023.10.31.xpi";
    sha256 = "37e96cbd257b73d7350605ed20494a82b578f25a2cefc3de2dab019e5ff6ced1";
    meta = with lib; {
      homepage = "https://privacybadger.org/";
      description = "Automatically learns to block invisible trackers.";
      license = licenses.gpl3;
      mozPermissions = [
        "alarms"
        "tabs"
        "http://*/*"
        "https://*/*"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "storage"
        "privacy"
        "https://*.facebook.com/*"
        "http://*.facebook.com/*"
        "https://*.messenger.com/*"
        "http://*.messenger.com/*"
        "*://*.facebookcorewwwi.onion/*"
        "https://docs.google.com/*"
        "http://docs.google.com/*"
        "https://mail.google.com/*"
        "http://mail.google.com/*"
        "https://www.google.com/*"
        "http://www.google.com/*"
        "https://www.google.ad/*"
        "http://www.google.ad/*"
        "https://www.google.ae/*"
        "http://www.google.ae/*"
        "https://www.google.com.af/*"
        "http://www.google.com.af/*"
        "https://www.google.com.ag/*"
        "http://www.google.com.ag/*"
        "https://www.google.com.ai/*"
        "http://www.google.com.ai/*"
        "https://www.google.al/*"
        "http://www.google.al/*"
        "https://www.google.am/*"
        "http://www.google.am/*"
        "https://www.google.co.ao/*"
        "http://www.google.co.ao/*"
        "https://www.google.com.ar/*"
        "http://www.google.com.ar/*"
        "https://www.google.as/*"
        "http://www.google.as/*"
        "https://www.google.at/*"
        "http://www.google.at/*"
        "https://www.google.com.au/*"
        "http://www.google.com.au/*"
        "https://www.google.az/*"
        "http://www.google.az/*"
        "https://www.google.ba/*"
        "http://www.google.ba/*"
        "https://www.google.com.bd/*"
        "http://www.google.com.bd/*"
        "https://www.google.be/*"
        "http://www.google.be/*"
        "https://www.google.bf/*"
        "http://www.google.bf/*"
        "https://www.google.bg/*"
        "http://www.google.bg/*"
        "https://www.google.com.bh/*"
        "http://www.google.com.bh/*"
        "https://www.google.bi/*"
        "http://www.google.bi/*"
        "https://www.google.bj/*"
        "http://www.google.bj/*"
        "https://www.google.com.bn/*"
        "http://www.google.com.bn/*"
        "https://www.google.com.bo/*"
        "http://www.google.com.bo/*"
        "https://www.google.com.br/*"
        "http://www.google.com.br/*"
        "https://www.google.bs/*"
        "http://www.google.bs/*"
        "https://www.google.bt/*"
        "http://www.google.bt/*"
        "https://www.google.co.bw/*"
        "http://www.google.co.bw/*"
        "https://www.google.by/*"
        "http://www.google.by/*"
        "https://www.google.com.bz/*"
        "http://www.google.com.bz/*"
        "https://www.google.ca/*"
        "http://www.google.ca/*"
        "https://www.google.cd/*"
        "http://www.google.cd/*"
        "https://www.google.cf/*"
        "http://www.google.cf/*"
        "https://www.google.cg/*"
        "http://www.google.cg/*"
        "https://www.google.ch/*"
        "http://www.google.ch/*"
        "https://www.google.ci/*"
        "http://www.google.ci/*"
        "https://www.google.co.ck/*"
        "http://www.google.co.ck/*"
        "https://www.google.cl/*"
        "http://www.google.cl/*"
        "https://www.google.cm/*"
        "http://www.google.cm/*"
        "https://www.google.cn/*"
        "http://www.google.cn/*"
        "https://www.google.com.co/*"
        "http://www.google.com.co/*"
        "https://www.google.co.cr/*"
        "http://www.google.co.cr/*"
        "https://www.google.com.cu/*"
        "http://www.google.com.cu/*"
        "https://www.google.cv/*"
        "http://www.google.cv/*"
        "https://www.google.com.cy/*"
        "http://www.google.com.cy/*"
        "https://www.google.cz/*"
        "http://www.google.cz/*"
        "https://www.google.de/*"
        "http://www.google.de/*"
        "https://www.google.dj/*"
        "http://www.google.dj/*"
        "https://www.google.dk/*"
        "http://www.google.dk/*"
        "https://www.google.dm/*"
        "http://www.google.dm/*"
        "https://www.google.com.do/*"
        "http://www.google.com.do/*"
        "https://www.google.dz/*"
        "http://www.google.dz/*"
        "https://www.google.com.ec/*"
        "http://www.google.com.ec/*"
        "https://www.google.ee/*"
        "http://www.google.ee/*"
        "https://www.google.com.eg/*"
        "http://www.google.com.eg/*"
        "https://www.google.es/*"
        "http://www.google.es/*"
        "https://www.google.com.et/*"
        "http://www.google.com.et/*"
        "https://www.google.fi/*"
        "http://www.google.fi/*"
        "https://www.google.com.fj/*"
        "http://www.google.com.fj/*"
        "https://www.google.fm/*"
        "http://www.google.fm/*"
        "https://www.google.fr/*"
        "http://www.google.fr/*"
        "https://www.google.ga/*"
        "http://www.google.ga/*"
        "https://www.google.ge/*"
        "http://www.google.ge/*"
        "https://www.google.gg/*"
        "http://www.google.gg/*"
        "https://www.google.com.gh/*"
        "http://www.google.com.gh/*"
        "https://www.google.com.gi/*"
        "http://www.google.com.gi/*"
        "https://www.google.gl/*"
        "http://www.google.gl/*"
        "https://www.google.gm/*"
        "http://www.google.gm/*"
        "https://www.google.gr/*"
        "http://www.google.gr/*"
        "https://www.google.com.gt/*"
        "http://www.google.com.gt/*"
        "https://www.google.gy/*"
        "http://www.google.gy/*"
        "https://www.google.com.hk/*"
        "http://www.google.com.hk/*"
        "https://www.google.hn/*"
        "http://www.google.hn/*"
        "https://www.google.hr/*"
        "http://www.google.hr/*"
        "https://www.google.ht/*"
        "http://www.google.ht/*"
        "https://www.google.hu/*"
        "http://www.google.hu/*"
        "https://www.google.co.id/*"
        "http://www.google.co.id/*"
        "https://www.google.ie/*"
        "http://www.google.ie/*"
        "https://www.google.co.il/*"
        "http://www.google.co.il/*"
        "https://www.google.im/*"
        "http://www.google.im/*"
        "https://www.google.co.in/*"
        "http://www.google.co.in/*"
        "https://www.google.iq/*"
        "http://www.google.iq/*"
        "https://www.google.is/*"
        "http://www.google.is/*"
        "https://www.google.it/*"
        "http://www.google.it/*"
        "https://www.google.je/*"
        "http://www.google.je/*"
        "https://www.google.com.jm/*"
        "http://www.google.com.jm/*"
        "https://www.google.jo/*"
        "http://www.google.jo/*"
        "https://www.google.co.jp/*"
        "http://www.google.co.jp/*"
        "https://www.google.co.ke/*"
        "http://www.google.co.ke/*"
        "https://www.google.com.kh/*"
        "http://www.google.com.kh/*"
        "https://www.google.ki/*"
        "http://www.google.ki/*"
        "https://www.google.kg/*"
        "http://www.google.kg/*"
        "https://www.google.co.kr/*"
        "http://www.google.co.kr/*"
        "https://www.google.com.kw/*"
        "http://www.google.com.kw/*"
        "https://www.google.kz/*"
        "http://www.google.kz/*"
        "https://www.google.la/*"
        "http://www.google.la/*"
        "https://www.google.com.lb/*"
        "http://www.google.com.lb/*"
        "https://www.google.li/*"
        "http://www.google.li/*"
        "https://www.google.lk/*"
        "http://www.google.lk/*"
        "https://www.google.co.ls/*"
        "http://www.google.co.ls/*"
        "https://www.google.lt/*"
        "http://www.google.lt/*"
        "https://www.google.lu/*"
        "http://www.google.lu/*"
        "https://www.google.lv/*"
        "http://www.google.lv/*"
        "https://www.google.com.ly/*"
        "http://www.google.com.ly/*"
        "https://www.google.co.ma/*"
        "http://www.google.co.ma/*"
        "https://www.google.md/*"
        "http://www.google.md/*"
        "https://www.google.me/*"
        "http://www.google.me/*"
        "https://www.google.mg/*"
        "http://www.google.mg/*"
        "https://www.google.mk/*"
        "http://www.google.mk/*"
        "https://www.google.ml/*"
        "http://www.google.ml/*"
        "https://www.google.com.mm/*"
        "http://www.google.com.mm/*"
        "https://www.google.mn/*"
        "http://www.google.mn/*"
        "https://www.google.ms/*"
        "http://www.google.ms/*"
        "https://www.google.com.mt/*"
        "http://www.google.com.mt/*"
        "https://www.google.mu/*"
        "http://www.google.mu/*"
        "https://www.google.mv/*"
        "http://www.google.mv/*"
        "https://www.google.mw/*"
        "http://www.google.mw/*"
        "https://www.google.com.mx/*"
        "http://www.google.com.mx/*"
        "https://www.google.com.my/*"
        "http://www.google.com.my/*"
        "https://www.google.co.mz/*"
        "http://www.google.co.mz/*"
        "https://www.google.com.na/*"
        "http://www.google.com.na/*"
        "https://www.google.com.ng/*"
        "http://www.google.com.ng/*"
        "https://www.google.com.ni/*"
        "http://www.google.com.ni/*"
        "https://www.google.ne/*"
        "http://www.google.ne/*"
        "https://www.google.nl/*"
        "http://www.google.nl/*"
        "https://www.google.no/*"
        "http://www.google.no/*"
        "https://www.google.com.np/*"
        "http://www.google.com.np/*"
        "https://www.google.nr/*"
        "http://www.google.nr/*"
        "https://www.google.nu/*"
        "http://www.google.nu/*"
        "https://www.google.co.nz/*"
        "http://www.google.co.nz/*"
        "https://www.google.com.om/*"
        "http://www.google.com.om/*"
        "https://www.google.com.pa/*"
        "http://www.google.com.pa/*"
        "https://www.google.com.pe/*"
        "http://www.google.com.pe/*"
        "https://www.google.com.pg/*"
        "http://www.google.com.pg/*"
        "https://www.google.com.ph/*"
        "http://www.google.com.ph/*"
        "https://www.google.com.pk/*"
        "http://www.google.com.pk/*"
        "https://www.google.pl/*"
        "http://www.google.pl/*"
        "https://www.google.pn/*"
        "http://www.google.pn/*"
        "https://www.google.com.pr/*"
        "http://www.google.com.pr/*"
        "https://www.google.ps/*"
        "http://www.google.ps/*"
        "https://www.google.pt/*"
        "http://www.google.pt/*"
        "https://www.google.com.py/*"
        "http://www.google.com.py/*"
        "https://www.google.com.qa/*"
        "http://www.google.com.qa/*"
        "https://www.google.ro/*"
        "http://www.google.ro/*"
        "https://www.google.ru/*"
        "http://www.google.ru/*"
        "https://www.google.rw/*"
        "http://www.google.rw/*"
        "https://www.google.com.sa/*"
        "http://www.google.com.sa/*"
        "https://www.google.com.sb/*"
        "http://www.google.com.sb/*"
        "https://www.google.sc/*"
        "http://www.google.sc/*"
        "https://www.google.se/*"
        "http://www.google.se/*"
        "https://www.google.com.sg/*"
        "http://www.google.com.sg/*"
        "https://www.google.sh/*"
        "http://www.google.sh/*"
        "https://www.google.si/*"
        "http://www.google.si/*"
        "https://www.google.sk/*"
        "http://www.google.sk/*"
        "https://www.google.com.sl/*"
        "http://www.google.com.sl/*"
        "https://www.google.sn/*"
        "http://www.google.sn/*"
        "https://www.google.so/*"
        "http://www.google.so/*"
        "https://www.google.sm/*"
        "http://www.google.sm/*"
        "https://www.google.sr/*"
        "http://www.google.sr/*"
        "https://www.google.st/*"
        "http://www.google.st/*"
        "https://www.google.com.sv/*"
        "http://www.google.com.sv/*"
        "https://www.google.td/*"
        "http://www.google.td/*"
        "https://www.google.tg/*"
        "http://www.google.tg/*"
        "https://www.google.co.th/*"
        "http://www.google.co.th/*"
        "https://www.google.com.tj/*"
        "http://www.google.com.tj/*"
        "https://www.google.tl/*"
        "http://www.google.tl/*"
        "https://www.google.tm/*"
        "http://www.google.tm/*"
        "https://www.google.tn/*"
        "http://www.google.tn/*"
        "https://www.google.to/*"
        "http://www.google.to/*"
        "https://www.google.com.tr/*"
        "http://www.google.com.tr/*"
        "https://www.google.tt/*"
        "http://www.google.tt/*"
        "https://www.google.com.tw/*"
        "http://www.google.com.tw/*"
        "https://www.google.co.tz/*"
        "http://www.google.co.tz/*"
        "https://www.google.com.ua/*"
        "http://www.google.com.ua/*"
        "https://www.google.co.ug/*"
        "http://www.google.co.ug/*"
        "https://www.google.co.uk/*"
        "http://www.google.co.uk/*"
        "https://www.google.com.uy/*"
        "http://www.google.com.uy/*"
        "https://www.google.co.uz/*"
        "http://www.google.co.uz/*"
        "https://www.google.com.vc/*"
        "http://www.google.com.vc/*"
        "https://www.google.co.ve/*"
        "http://www.google.co.ve/*"
        "https://www.google.vg/*"
        "http://www.google.vg/*"
        "https://www.google.co.vi/*"
        "http://www.google.co.vi/*"
        "https://www.google.com.vn/*"
        "http://www.google.com.vn/*"
        "https://www.google.vu/*"
        "http://www.google.vu/*"
        "https://www.google.ws/*"
        "http://www.google.ws/*"
        "https://www.google.rs/*"
        "http://www.google.rs/*"
        "https://www.google.co.za/*"
        "http://www.google.co.za/*"
        "https://www.google.co.zm/*"
        "http://www.google.co.zm/*"
        "https://www.google.co.zw/*"
        "http://www.google.co.zw/*"
        "https://www.google.cat/*"
        "http://www.google.cat/*"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "promnesia" = rec {
    pname = "promnesia";
    version = "1.2.4";
    addonId = "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4110600/promnesia-1.2.4.xpi";
    sha256 = "1f35b9e14ac88c250965fd5dbbb03a2a4dce869807484c3be23afc53eb388cee";
    meta = with lib; {
      homepage = "https://github.com/karlicoss/promnesia";
      description = "Enhancement of your browsing history";
      license = licenses.mit;
      mozPermissions = [
        "file:///*"
        "https://*/*"
        "http://*/*"
        "storage"
        "webNavigation"
        "contextMenus"
        "notifications"
        "bookmarks"
        "history"
      ];
      platforms = platforms.all;
    };
  };
  "reduxdevtools" = rec {
    pname = "reduxdevtools";
    version = "3.1.3";
    addonId = "extension@redux.devtools";
    url = "https://addons.mozilla.org/firefox/downloads/file/4168659/reduxdevtools-3.1.3.xpi";
    sha256 = "c69faa457c84e32ae58ab4873a8ee9f6a0615615cb5fe242c2ffe55feb407c1d";
    meta = with lib; {
      homepage = "https://github.com/reduxjs/redux-devtools";
      description = "DevTools for Redux with actions history, undo and replay.";
      license = licenses.mit;
      mozPermissions = [
        "notifications"
        "contextMenus"
        "tabs"
        "storage"
        "file:///*"
        "http://*/*"
        "https://*/*"
        "devtools"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "russian-spellchecking-dic-3703" = rec {
    pname = "russian-spellchecking-dic-3703";
    version = "0.4.5.1webext";
    addonId = "ru@dictionaries.addons.mozilla.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/1163927/russian_spellchecking_dic_3703-0.4.5.1webext.xpi";
    sha256 = "8681bfbc86a8aa2c211638b97792dca42e3599f79b6cf456b32aebea711c0f1a";
    meta = with lib; {
      homepage = "http://www.mozilla-russia.org";
      description = "Russian spellchecking dictionary";
      license = licenses.bsd2;
      mozPermissions = [];
      platforms = platforms.all;
    };
  };
  "swisscows-search" = rec {
    pname = "swisscows-search";
    version = "1.4";
    addonId = "swisscows@swisscows.ch";
    url = "https://addons.mozilla.org/firefox/downloads/file/3729573/swisscows_search-1.4.xpi";
    sha256 = "a7e104f230be11733e2cdda556ba2fe423cf6c883a7150c9c078c516b3b183db";
    meta = with lib; {
      description = "Adds Swisscows as the default search engine in your browser.";
      license = licenses.mit;
      mozPermissions = [];
      platforms = platforms.all;
    };
  };
  "temporary-containers" = rec {
    pname = "temporary-containers";
    version = "1.9.2";
    addonId = "{c607c8df-14a7-4f28-894f-29e8722976af}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3723251/temporary_containers-1.9.2.xpi";
    sha256 = "3340a08c29be7c83bd0fea3fc27fde71e4608a4532d932114b439aa690e7edc0";
    meta = with lib; {
      homepage = "https://github.com/stoically/temporary-containers";
      description = "Open tabs, websites, and links in automatically managed disposable containers which isolate the data websites store (cookies, storage, and more) from each other, enhancing your privacy and security while you browse.";
      license = licenses.mit;
      mozPermissions = [
        "<all_urls>"
        "contextMenus"
        "contextualIdentities"
        "cookies"
        "management"
        "storage"
        "tabs"
        "webRequest"
        "webRequestBlocking"
      ];
      platforms = platforms.all;
    };
  };
  "ublock-origin" = rec {
    pname = "ublock-origin";
    version = "1.54.0";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-1.54.0.xpi";
    sha256 = "9797160908191710ff0858536ba6dc29ecad9923c30b2ad6d3e5e371d759e44d";
    meta = with lib; {
      homepage = "https://github.com/gorhill/uBlock#ublock-origin";
      description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
      license = licenses.gpl3;
      mozPermissions = [
        "dns"
        "menus"
        "privacy"
        "storage"
        "tabs"
        "unlimitedStorage"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "<all_urls>"
        "http://*/*"
        "https://*/*"
        "file://*/*"
        "https://easylist.to/*"
        "https://*.fanboy.co.nz/*"
        "https://filterlists.com/*"
        "https://forums.lanik.us/*"
        "https://github.com/*"
        "https://*.github.io/*"
        "https://*.letsblock.it/*"
        "https://github.com/uBlockOrigin/*"
        "https://ublockorigin.github.io/*"
        "https://*.reddit.com/r/uBlockOrigin/*"
      ];
      platforms = platforms.all;
    };
  };
  "ugetintegration" = rec {
    pname = "ugetintegration";
    version = "2.1.3.1";
    addonId = "uget-integration@slgobinath";
    url = "https://addons.mozilla.org/firefox/downloads/file/911315/ugetintegration-2.1.3.1.xpi";
    sha256 = "235f29ca5df79e4e5a338e29ef7cd721bb7873309b56364cc7a4bf4612e1ae85";
    meta = with lib; {
      homepage = "https://github.com/ugetdm/uget-integrator";
      description = "Integrate Mozilla Firefox with uGet download manager.\nPlease note that \"uget-chrome-wrapper\" has been renamed to \"uget-integrator\".\n<a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/e231fe36249ab4182cf0474166b098eb0ac98e7813be8faff0618be919e234f3/https%3A//github.com/ugetdm/uget-integrator\">https://github.com/ugetdm/uget-integrator</a>";
      license = licenses.lgpl3;
      mozPermissions = [
        "<all_urls>"
        "webRequest"
        "webRequestBlocking"
        "nativeMessaging"
        "contextMenus"
        "downloads"
        "storage"
        "cookies"
        "activeTab"
        "tabs"
      ];
      platforms = platforms.all;
    };
  };
  "umatrix" = rec {
    pname = "umatrix";
    version = "1.4.4";
    addonId = "uMatrix@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/3812704/umatrix-1.4.4.xpi";
    sha256 = "1de172b1d82de28c334834f7b0eaece0b503f59e62cfc0ccf23222b8f2cb88e5";
    meta = with lib; {
      homepage = "https://github.com/gorhill/uMatrix";
      description = "Point &amp; click to forbid/allow any class of requests made by your browser. Use it to block scripts, iframes, ads, facebook, etc.";
      license = licenses.gpl3;
      mozPermissions = [
        "browsingData"
        "cookies"
        "privacy"
        "storage"
        "tabs"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "<all_urls>"
        "http://*/*"
        "https://*/*"
      ];
      platforms = platforms.all;
    };
  };
}