{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    mkMerge
    toString;

  psql_port = toString config.services.postgresql.settings.port;
  cfgDir = ''conf_dir=$(systemctl cat pdns.service | grep -i config-dir | awk -F ' ' '{printf $2}' | awk -F '=' '{printf $2}')'';
  param = ''--config-dir="''${conf_dir}" $@'';

in
mkMerge [
  {
    # networking.firewall.interfaces."kea-dhcp".allowedUDPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    # systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "pdnsutil" ''
        ${cfgDir}
        ${pkgs.powerdns}/bin/pdnsutil ${param}
      '')

      (pkgs.writeShellScriptBin "pdns_control" ''
        ${cfgDir}
        ${pkgs.powerdns}/bin/pdns_control ${param}
      '')
    ];

    systemd.services.pdns.path = with pkgs; [ libressl.nc ];
    systemd.services.pdns.preStart = ''
      until nc -d -z 127.0.0.1 ${psql_port};do echo 'waiting for sql server for 5 sec.' && sleep 5;done
    '';

    # FIXME: test credentials!
    services.powerdns = {
      enable = true;
      # default-soa-name=njk.local <- removed with upgrade
      # FIXME: https://docs.powerdns.com/authoritative/settings.html#setting-default-soa-content
      #
      #
      extraConfig = ''
        local-address=0.0.0.0:5353

        webserver-allow-from=127.0.0.1
        webserver-address=127.0.0.1

        dnsupdate=yes
        allow-dnsupdate-from=127.0.0.1/32

        api=yes
        api-key=testkey

        version-string=powerdns

        launch=gpgsql

        gpgsql-host=127.0.0.1
        gpgsql-port=${psql_port}
        gpgsql-user=powerdns
        gpgsql-dbname=powerdns
        gpgsql-dnssec=yes
      '';
      #         master=yes
    };
  }
]
