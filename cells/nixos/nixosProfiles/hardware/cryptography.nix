{ inputs, cell, ... }:

#
# https://raymii.org/s/articles/GPG_noninteractive_batch_sign_trust_and_send_gnupg_keys.html
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
{ config, lib, pkgs, ... }:
with lib;
let
  hmModule = { osConfig, lib, pkgs, config, ... }:
    let
      inherit (lib) mkDefault mkIf mkEnableOption;
      package = (pkgs.writeShellScriptBin "pinentry-selector" ''
        if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
          exec ${pkgs.pinentry-all}/bin/pinentry-gnome3
        else
          exec ${pkgs.pinentry-all}/bin/pinentry-curses
        fi
      '') // { meta = { mainProgram = "pinentry-selector"; }; };
      cfg = config.gui;
    in
    {
      options.gui.enable = mkEnableOption "gtk3 pinentry" // { default = true; };
      config = mkIf cfg.enable
        {
          # NOTE: chatty log pollution
          # home.sessionVariables.G_MESSAGES_DEBUG = "none";
          systemd.user.services.gpg-agent.Service.StandardOutput = "null";

          programs.gpg.enable = mkDefault true;
          programs.gpg.mutableKeys = mkDefault true;
          programs.gpg.mutableTrust = mkDefault true;

          # NOTE: This is needed to support multiple keys
          programs.gpg.scdaemonSettings.disable-ccid = osConfig.services.pcscd.enable;

          home.packages = [ pkgs.pinentry-all ];

          services.gpg-agent = {
            pinentry = { inherit package; };
            enable = mkDefault true;
            enableSshSupport = mkDefault true;
            enableExtraSocket = mkDefault true;
            defaultCacheTtl = 3 * 60 * 60; # 3 hours
            defaultCacheTtlSsh = 3 * 60 * 60; # 3 hours
            extraConfig = ''
              allow-emacs-pinentry
              allow-loopback-pinentry
            '';
          };
        };
    };

in
mkMerge [
  {
    home-manager.sharedModules = [ hmModule ];

    # NOTE chatty log pollution
    systemd.services.pcscd.serviceConfig.StandardOutput = "null";

    # NOTE: No longer interested in yubikeys
    # security.pam.yubico.debug = false;
    # security.pam.yubico.enable = true;
    # security.pam.yubico.mode = "challenge-response";
    # security.pam.yubico.control = "sufficient";
    # security.pam.yubico.challengeResponsePath = "/var/lib/yubico";

    # NOTE: This enables trezor logins
    security.pam.u2f.enable = mkDefault true;
    security.pam.u2f.control = "sufficient";

    hardware.ledger.enable = mkDefault true;
    hardware.nitrokey.enable = mkDefault true;
    hardware.gpgSmartcards.enable = mkDefault true;

    services.trezord.enable = mkDefault true;
    services.pcscd.enable = mkDefault true;

    # services.pcscd.plugins = [ pkgs.acsccid ];
    # programs.gnupg.dirmngr.enable = true;

    # nitrokey-udev-rules
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    environment.systemPackages = with pkgs; [
      # TODO: trezor_agent_recover
      # trezor_agent
      # trezorctl

      # NOTE: https://github.com/dhess/nixos-yubikey
      python3Packages.pynitrokey # Python client for Nitrokey devices

      yubikey-personalization
      yubikey-manager
      yubikey-touch-detector
      yubico-piv-tool
      yubico-pam
      pam_u2f

      # age-plugin-yubikey
      # rage

      pcsclite

      # inputs.cells.common.packages.pbkdf2-sha512
      cryptsetup
      openssl
      paperkey
      qrencode

      ###
      inputs.cells.common.packages.paper-store
      # gpg-tui # NOTE: Fuck rust
      ###
      inputs.cells.common.packages.pgp-key-generation # Deterministic ssh-keys from BIP39
      inputs.cells.common.packages.dkeygen # helper script for pgp-key-generation
      inputs.cells.common.packages.bip39key # Generate an OpenPGP key from a BIP39 mnemonic
      passphrase2pgp # Predictable, passphrase-based PGP key generator
      enc # Modern and friendly alternative to GnuPG
    ];

    environment.interactiveShellInit = ''
      rbtohex() {
        ( od -An -vtx1 | tr -d ' \n' )
      }

      hextorb() {
        ( tr '[:lower:]' '[:upper:]' | sed -e 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI'| xargs printf )
      }
    '';

  }

  (mkIf (cell.lib.isGui config) {
    # TODO: Lock screen when trezor device is removed via udev.
    # udevadm info --attribute-walk --name /dev/usb/hiddev0
    #
    # for a device I got on hand:
    # ATTRS{serial}=="1479D05D54BB75B5ACC18119"
    # ATTRS{manufacturer}=="SatoshiLabs"
    # ATTRS{idProduct}=="53c1"
    # ATTRS{idVendor}=="1209"

    # NOTE: https://gitlab.gnome.org/GNOME/gcr/-/issues/78 - gcr is very chatty!
    environment.sessionVariables.G_MESSAGES_DEBUG = "none";
    # services.journald.extraConfig = "Suppress=gcr-prompter";
    # systemd.services."org.gnome.keyring.SystemPrompter".serviceConfig.StandardOutput = "null";
    # systemd.services."org.gnome.keyring.SystemPrompter".serviceConfig.StandardError = "null";

    services.dbus.packages =
      let
        # TODO: reference a systemd service instead and have it redirect output to null
        # StandardOutput=null
        # StandardError=null
        PrivatePrompter = ''
          [D-BUS Service]
          Name=org.gnome.keyring.PrivatePrompter
          Exec=${pkgs.gcr}/libexec/gcr-prompter
        '';
        SystemPrompter = ''
          [D-BUS Service]
          Name=org.gnome.keyring.SystemPrompter
          Exec=${pkgs.gcr}/libexec/gcr-prompter
        '';
      in
      # TODO: replace gcr with pkgs.wayprompt -  https://git.sr.ht/~leon_plickat/wayprompt
      [ pkgs.gcr ];
    environment.systemPackages = with pkgs; [
      # gcr
      # sirikali # GUI front end to sshfs,ecryptfs,cryfs,gocryptfs,securefs,fscrypt,encfs
      gpa # Graphical user interface for the GnuPG
      yubikey-personalization-gui
      yubioath-flutter
      zbar
      pcsctools

      # yubioath-desktop
      # yubioath-flutter
      # trezor-suite
      nitrokey-app
      ledger-live-desktop
    ];
  })

]
