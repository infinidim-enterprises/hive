{ inputs, cell, ... }:

{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  # FIXME: Unable to start GeoClue client: GDBus.Error:org.freedesktop.DBus.Error.AccessDenied: 'redshift' disallowed, no agent for UID 1000
  services.geoclue2.enable = mkDefault true;
  services.geoclue2.enableNmea = false;
  services.geoclue2.enable3G = false;
  services.geoclue2.enableCDMA = false;
  services.geoclue2.enableModemGPS = false;
  services.geoclue2.enableWifi = false;

  services.geoclue2.submitData = false;
  services.geoclue2.enableDemoAgent = true;

  location.provider = mkDefault "geoclue2";

  # location.longitude = mkDefault 50.123929;
  # location.latitude = mkDefault 8.6402113;

  # NOTE: https://sourceware.org/git/?p=glibc.git;a=blob;f=localedata/SUPPORTED
  time.timeZone = mkDefault "Europe/Berlin";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  i18n.supportedLocales = mkDefault [
    "ru_RU.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings.LC_MESSAGES = mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_CTYPE = mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = mkDefault "en_GB.UTF-8";
  i18n.extraLocaleSettings.LC_NUMERIC = mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_PAPER = mkDefault "de_DE.UTF-8";
  i18n.extraLocaleSettings.LC_TELEPHONE = mkDefault "de_DE.UTF-8";
  i18n.extraLocaleSettings.LC_MONETARY = mkDefault "de_DE.UTF-8";
  i18n.extraLocaleSettings.LC_ADDRESS = mkDefault "de_DE.UTF-8";
  i18n.extraLocaleSettings.LC_MEASUREMENT = mkDefault "de_DE.UTF-8";
  i18n.extraLocaleSettings.LC_COLLATE = mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_NAME = mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_IDENTIFICATION = mkDefault "en_US.UTF-8";

  services.timesyncd.servers = mkDefault [
    "0.europe.pool.ntp.org"
    "1.europe.pool.ntp.org"
    "2.europe.pool.ntp.org"
    "3.europe.pool.ntp.org "
  ];
}
