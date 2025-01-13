{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

let
  inherit (lib // builtins)
    mkIf
    types
    toInt
    isNull
    mkMerge
    mkForce
    toUpper
    toString
    mkOption
    hasSuffix
    hasAttrByPath
    concatStrings
    mapAttrsToList
    optionalString
    mkEnableOption;

  psql_port = toString config.services.postgresql.settings.port;
  cfgDir = ''conf_dir=$(systemctl cat pdns.service | grep -i config-dir | awk -F ' ' '{printf $2}' | awk -F '=' '{printf $2}')'';
  param = ''--config-dir="''${conf_dir}" $@'';

in
{
  imports = [ cell.nixosModules.services.networking.powerdns ];

  config = mkMerge [
    (mkIf (hasAttrByPath [ "sops" "secrets" ] config) {
      sops.secrets.powerdns = {
        sopsFile = ../../../../secrets/sops/powerdns;
        restartUnits = [ "pdns.service" ];
        format = "binary";
      };
    })

    {
      # networking.firewall.interfaces."njk.local".allowedUDPPorts = [ 5353 ];
      # networking.firewall.allowedUDPPorts = [ 53 ];

      environment.systemPackages =
        # (mapAttrsToList (n: v: v.initScript) config.services.powerdns.zones) ++
        [
          (pkgs.writeShellScriptBin "pdnsutil" ''
            ${cfgDir}
            ${pkgs.powerdns}/bin/pdnsutil ${param}
          '')

          (pkgs.writeShellScriptBin "pdns_control" ''
            ${cfgDir}
            ${pkgs.powerdns}/bin/pdns_control ${param}
          '')
        ];

      services.powerdns = {
        settings = {
          api = "yes";

          launch = "gpgsql";
          gpgsql-host = "127.0.0.1";
          gpgsql-port = psql_port;
          gpgsql-user = "powerdns";
          gpgsql-dbname = "powerdns";
          gpgsql-dnssec = "yes";
        };

        virtualInstances.default.enable = true;
        virtualInstances.default.secretsFile = config.sops.secrets.powerdns.path;
        virtualInstances.default.settings = {
          local-address = "0.0.0.0";
          local-port = "5353";

          webserver-allow-from = "127.0.0.1";
          webserver-address = "127.0.0.1";
          webserver-port = "8081";

          dnsupdate = "yes";
          allow-dnsupdate-from = "127.0.0.1/32";

          # default-soa-edit = "INCREASE";
          default-api-rectify = "yes";
          default-ttl = "60";
          dnssec-key-cache-ttl = "0";

          version-string = "full";
        };
      };
    }
  ];
}
