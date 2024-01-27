{ inputs, cell, ... }:

{ config, lib, pkgs, containers, ... }:
with lib;
let
  cfg = config.deploy.params.lan.server.dns-native;
  lan = config.deploy.params.lan.server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  sqlHostAddress = head (splitString "/" (head (lan.postgresql.addresses)).addressConfig.Address);
  keaHostAddress = head (splitString "/" (head (lan.kea-dhcp.addresses)).addressConfig.Address);
  sameHost = hasAttrByPath [ "containers" "postgresql-dns-dhcp" ] config;
  cfgDir = ''conf_dir=$(systemctl cat pdns.service | grep -i config-dir | awk -F ' ' '{printf $2}' | awk -F '=' '{printf $2}')'';
  param = ''--config-dir="''${conf_dir}" $@'';
  namespace = "lan-" + lan.domain;
in
mkMerge [
  (mkIf sameHost {
    systemd.services."container@${namespace}-powerdns-native" = {
      after = [ "container@${namespace}-postgresql-dns-dhcp.service" ];
      partOf = [ "container@${namespace}-postgresql-dns-dhcp.service" ];
    };
  })

  {
    containers."${namespace}-powerdns-native" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_CHOWN" ];
      inherit (lan) macvlans;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;
      config = { pkgs, ... }:
        {
          imports = containers.systemd;
          networking.hostName = "powerdns-native";
          networking.domain = lan.domain;
          networking.firewall.allowedUDPPorts = [ 53 ];
          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

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
            until nc -d -z ${sqlHostAddress} 5432;do echo 'waiting for sql server for 5 sec.' && sleep 5;done
          '';

          # FIXME: test credentials!
          services.powerdns = {
            enable = true;
            # default-soa-name=njk.local <- removed with upgrade
            # FIXME: https://docs.powerdns.com/authoritative/settings.html#setting-default-soa-content
            extraConfig = ''
              local-address=${localAddress}
              webserver-allow-from=${lan.network}
              webserver-address=${localAddress}
              dnsupdate=yes
              allow-dnsupdate-from=${keaHostAddress}/32

              api=yes
              api-key=testkey

              master=yes
              version-string=powerdns
              launch=gpgsql
              gpgsql-host=${sqlHostAddress}
              gpgsql-user=powerdns
              gpgsql-password=powerdns
              gpgsql-dbname=powerdns
              gpgsql-dnssec=yes
            '';

          };
        };
    };

  }
]
