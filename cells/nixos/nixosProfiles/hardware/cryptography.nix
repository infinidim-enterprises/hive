{ inputs, cell, ... }:

#
# https://raymii.org/s/articles/GPG_noninteractive_batch_sign_trust_and_send_gnupg_keys.html
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
{ config, lib, pkgs, ... }:
with lib;
let
  hmModule = { config, osConfig, lib, ... }:
    {
      config = with lib; mkMerge [
        {
          # NOTE: chatty log pollution
          systemd.user.services.gpg-agent.Service.StandardOutput = "null";

          programs.gpg.enable = mkDefault true;
          programs.gpg.mutableKeys = mkDefault true;
          programs.gpg.mutableTrust = mkDefault true;

          # NOTE: This is needed to support multiple keys
          programs.gpg.scdaemonSettings.disable-ccid = osConfig.services.pcscd.enable;

          services.gpg-agent.enable = mkDefault true;
          services.gpg-agent.enableSshSupport = mkDefault true;
          services.gpg-agent.enableExtraSocket = mkDefault true;
          # services.gpg-agent.pinentryPackage = mkDefault pkgs.pinentry-gnome3;
          services.gpg-agent.extraConfig = ''
            allow-emacs-pinentry
            allow-loopback-pinentry
          '';
        }
      ];
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
    security.pam.u2f.enable = true;
    security.pam.u2f.control = "sufficient";

    hardware.ledger.enable = true;
    hardware.nitrokey.enable = true;
    hardware.gpgSmartcards.enable = true;

    services.trezord.enable = true;
    services.pcscd.enable = true;

    # services.pcscd.plugins = [ pkgs.acsccid ];
    # programs.gnupg.dirmngr.enable = true;

    services.udev.packages = with pkgs; [ yubikey-personalization ];

    environment.systemPackages = with pkgs; [
      # TODO: trezor_agent_recover
      trezor_agent
      trezorctl

      # NOTE: https://github.com/dhess/nixos-yubikey
      yubikey-personalization
      yubikey-manager
      yubikey-touch-detector
      yubico-piv-tool
      yubico-pam
      pam_u2f

      # age-plugin-yubikey
      # rage

      pcsclite
      pcsctools

      inputs.cells.common.packages.pbkdf2-sha512
      cryptsetup
      openssl
      paperkey
      qrencode
      zbar

      ###
      inputs.cells.common.packages.paper-store
      # gpg-tui # NOTE: Fuck rust
      ###
      inputs.cells.common.packages.pgp-key-generation # Deterministic ssh-keys from BIP39
      inputs.cells.common.packages.dkeygen # helper script for pgp-key-generation
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
    systemd.services."org.gnome.keyring.SystemPrompter".serviceConfig.StandardOutput = "null";
    systemd.services."org.gnome.keyring.SystemPrompter".serviceConfig.StandardError = "null";

    # FIXME: pkgs.gcr appear twice in services.dbus.packages. why?
    services.dbus.packages = [ pkgs.gcr ];
    environment.systemPackages = with pkgs; [
      # gcr
      sirikali # GUI front end to sshfs,ecryptfs,cryfs,gocryptfs,securefs,fscrypt,encfs
      gpa # Graphical user interface for the GnuPG
      yubikey-personalization-gui
      yubikey-manager-qt
      # yubioath-desktop
      yubioath-flutter
      trezor-suite
      nitrokey-app
      ledger-live-desktop
    ];
  })

]
