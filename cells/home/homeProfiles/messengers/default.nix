{ pkgs, lib, config, ... }:
let
  inherit (lib) mkMerge mkIf;
in
mkMerge [
  {
    home.packages = with pkgs; [
      # TODO: move it into a separate profile
      # bisq-desktop

      tdesktop
      # TODO: signald # Unofficial daemon for interacting with Signal
      signal-desktop
      element-desktop
      # vesktop # Discord with Vencord built-in
      linphone
      baresip
      # NOTE: defunct jitsi
      # qtox # Qt Tox client
      utox # Lightweight Tox client
      # nym # NOTE: fuck rust. Mixnet providing IP-level privacy
      localsend # Open source cross-platform alternative to AirDrop
    ];
  }

  (mkIf config.xdg.mimeApps.enable {
    xdg.mimeApps.defaultApplications."x-scheme-handler/tg" = "org.telegram.desktop.desktop";
    xdg.mimeApps.defaultApplications."x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";

    xdg.mimeApps.associations.added."x-scheme-handler/tg" = "org.telegram.desktop.desktop";
    xdg.mimeApps.associations.added."x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
  })
]
