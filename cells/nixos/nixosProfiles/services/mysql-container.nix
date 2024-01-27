{ inputs, cell, ... }:

{ containers, ... }:

{
  containers.mysql-playground = {
    additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    macvlans = [ "lan" ];

    timeoutStartSec = "120s";
    autoStart = true;
    ephemeral = true;
    config = { pkgs, ... }:
      {
        imports = containers.systemd;
        networking.hostName = "mysql-playground";
        networking.domain = "njk.local";
        networking.firewall.allowedTCPPorts = [ 3306 ];

        systemd.network.networks.lan.dhcpV4Config.ClientIdentifier = "mac";
        systemd.network.networks.lan.linkConfig.MACAddress = "00:F1:50:00:1a:f0";

        services.mysql = {
          enable = true;
          settings.mysqld.bind = "0.0.0.0";
          settings.mysqld.port = 3306;
          package = pkgs.mariadb;
          ensureDatabases = [ "ia" ];
          ensureUsers = [{ name = "ia"; ensurePermissions = { "ia.*" = "ALL PRIVILEGES"; }; }];

          # initialScript = pkgs.writeText "mariadb-init.sql" ''
          #   CREATE USER IF NOT EXISTS 'ia'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD("secret");
          #   CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD("supersecret");
          #   CREATE DATABASE IF NOT EXISTS ia;
          #   GRANT ALL PRIVILEGES ON ia.* TO 'ia'@'%';
          #   GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
          # '';
        };

      };
  };
}
