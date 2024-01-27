{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.pass-secret-service;

  dbusServiceFile = pkgs.writeTextFile rec {
    name = "org.freedesktop.secrets.service";
    destination = "/share/dbus-1/services/${name}";
    text = ''
      [D-BUS Service]
      Name=org.freedesktop.secrets
      Exec=${pkgs.coreutils}/bin/false
      SystemdService=dbus-org.freedesktop.secrets.service
    '';
  };

in
{
  options.services.pass-secret-service = {
    enable = mkEnableOption "Expose the libsecret dbus api with pass as backend / Alternative to gnome-keyring";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.dbus.packages = [ dbusServiceFile ];

      systemd.user.services."dbus-org.freedesktop.secrets" = {
        description = "Expose the libsecret dbus api with pass as backend";
        unitConfig.Documentation = "https://github.com/mdellweg/pass_secret_service";
        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.secrets";
          ExecStart = "${pkgs.pass-secret-service}/bin/pass_secret_service --path \${PASSWORD_STORE_DIR}";
        };
      };

    })
  ];
}
