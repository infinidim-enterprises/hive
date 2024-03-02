{ inputs, cell, ... }:

# NOTE: https://github.com/sgillespie/nixos-yubikey-luks
#
# https://raymii.org/s/articles/GPG_noninteractive_batch_sign_trust_and_send_gnupg_keys.html
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
{ config, lib, pkgs, ... }:
with lib;
let
  # scdaemonDisableCcid = pkgs.stdenv.mkDerivation {
  #   pname = "scdaemon-disable-ccid";
  #   version = cfg.package.version;
  #   phases = [ "installPhase" ];
  #   nativeBuildInputs = [ pkgs.makeWrapper ];
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     makeWrapper ${cfg.package}/libexec/scdaemon $out/bin/scdaemon-disable-ccid --add-flags --disable-ccid
  #   '';
  # };

  # gpgAgentExtraArgs =
  #   (lib.optional (cfg.agent.pinentryFlavor != null) "--pinentry-program ${pkgs.pinentry.${cfg.agent.pinentryFlavor}}/bin/pinentry")
  #   ++ (lib.optional config.services.pcscd.enable "--scdaemon-program ${scdaemonDisableCcid}/bin/scdaemon-disable-ccid");

  hmModule = { config, osConfig, lib, ... }:
    let
      cfgTrezor = config.services.trezor-agent;
      # homedir = config.programs.gpg.homedir;
      # gpgconf = dir:
      #   let
      #     hash = substring 0 24 (hexStringToBase32 (builtins.hashString "sha1" homedir));
      #   in
      #   if homedir == config.programs.gpg.homedir then
      #     "%t/gnupg/${dir}"
      #   else
      #     "%t/gnupg/d.${hash}/${dir}";
      # hexStringToBase32 =
      #   let
      #     mod = a: b: a - a / b * b;
      #     pow2 = elemAt [ 1 2 4 8 16 32 64 128 256 ];
      #     splitChars = s: init (tail (splitString "" s));

      #     base32Alphabet = splitChars "ybndrfg8ejkmcpqxot1uwisza345h769";
      #     hexToIntTable = listToAttrs (genList (value: { name = toLower (toHexString value); inherit value; }) 16);

      #     initState = { ret = ""; buf = 0; bufBits = 0; };
      #     go = { ret, buf, bufBits }: hex:
      #       let
      #         buf' = buf * pow2 4 + hexToIntTable.${hex};
      #         bufBits' = bufBits + 4;
      #         extraBits = bufBits' - 5;
      #       in
      #       if bufBits >= 5 then {
      #         ret = ret + elemAt base32Alphabet (buf' / pow2 extraBits);
      #         buf = mod buf' (pow2 extraBits);
      #         bufBits = bufBits' - 5;
      #       } else {
      #         inherit ret;
      #         buf = buf';
      #         bufBits = bufBits';
      #       };
      #   in
      #   hexString: (foldl' go initState (splitChars hexString)).ret;
    in
    {
      config = with lib; mkMerge [
        {
          # NOTE: chatty log pollution
          systemd.user.services.gpg-agent.Service.StandardOutput = "null";

          programs.gpg.enable = mkDefault true;
          programs.gpg.mutableKeys = mkDefault true;
          programs.gpg.mutableTrust = mkDefault true;
          programs.gpg.scdaemonSettings.disable-ccid = lib.mkIf osConfig.services.pcscd.enable true; # NOTE: This is needed to support multiple keys
        }
        (mkIf cfgTrezor.enable { })
        (mkIf (!cfgTrezor.enable) {
          services.gpg-agent.enable = mkDefault true;
          services.gpg-agent.enableSshSupport = mkDefault true;
          services.gpg-agent.enableExtraSocket = mkDefault true;
          services.gpg-agent.pinentryFlavor = mkDefault "gnome3";
          services.gpg-agent.extraConfig = ''
            allow-emacs-pinentry
            allow-loopback-pinentry
          '';
        })

      ];

      # systemd.user.sockets.gpg-agent-browser = {
      #   Unit.Description = "GnuPG cryptographic agent and passphrase cache (browser)";
      #   Unit.Documentation = "man:gpg-agent(1)";
      #   Socket.ListenStream = gpgconf "S.gpg-agent.browser";
      #   Socket.FileDescriptorName = "browser";
      #   Socket.Service = "gpg-agent.service";
      #   Socket.SocketMode = "0600";
      #   Socket.DirectoryMode = "0700";
      #   Install.WantedBy = [ "sockets.target" ];
      # };
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
      rage

      pcsclite
      pcsctools

      # pinentry-curses

      inputs.cells.common.packages.pbkdf2-sha512
      cryptsetup
      openssl

      # TODO: key backup
      ###
      inputs.cells.common.packages.paper-store
      # enc_with_passwd
      # gpg_autogenkey

      ###
      inputs.cells.common.packages.gpg-hd # Deterministic ssh-keys from BIP39
      paperkey
      qrencode
      zbar
    ];

    environment.shellInit = ''
      rbtohex() {
        ( od -An -vtx1 | tr -d ' \n' )
      }

      hextorb() {
        ( tr '[:lower:]' '[:upper:]' | sed -e 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI'| xargs printf )
      }
    '';

  }

  (mkIf config.services.xserver.displayManager.lightdm.enable {
    # TODO: Lock screen when trezor device is removed via udev.
    # udevadm info --attribute-walk --name /dev/usb/hiddev0
    #
    # for a device I got on hand:
    # ATTRS{serial}=="1479D05D54BB75B5ACC18119"
    # ATTRS{manufacturer}=="SatoshiLabs"
    # ATTRS{idProduct}=="53c1"
    # ATTRS{idVendor}=="1209"

    environment.systemPackages = with pkgs; [
      gcr
      gpa
      yubikey-personalization-gui
      yubikey-manager-qt
      # yubioath-desktop
      yubioath-flutter
      trezor-suite
      nitrokey-app
      # FIXME: warnings on collisions ledger-live-desktop
      ledger-live-desktop
    ];
  })

]
