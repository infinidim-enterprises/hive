{ pkgs, lib, config, ... }:
let
  inherit (lib) mkMerge mkIf genAttrs;
in
mkMerge [
  {
    home.packages = with pkgs; [
      # TODO: move it into a separate profile
      # bisq-desktop

      # matterbridge
      # dino # jabber/xmpp
      # FIXME; tdesktop
      # TODO: signald # Unofficial daemon for interacting with Signal
      signal-desktop
      # element-desktop
      # vesktop # Discord with Vencord built-in
      linphone
      # baresip
      # NOTE: defunct jitsi
      # qtox # Qt Tox client
      # utox # Lightweight Tox client
      # nym # NOTE: fuck rust. Mixnet providing IP-level privacy
      # localsend # Open source cross-platform alternative to AirDrop
    ];
  }

  (mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications =
      (genAttrs [
        "x-scheme-handler/tg"
        "x-scheme-handler/tonsite"
      ]
        (_: "org.telegram.desktop.desktop"))

      // (genAttrs [
        "x-scheme-handler/sgnl"
        "x-scheme-handler/signalcaptcha"
      ]
        (_: "signal-desktop.desktop"));
  })
]
