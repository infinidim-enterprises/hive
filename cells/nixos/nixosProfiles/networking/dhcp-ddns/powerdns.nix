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
    mkDefault
    fileContents
    hasAttrByPath
    concatStrings
    mapAttrsToList
    optionalString
    mkEnableOption;

  psql_port = toString config.services.postgresql.settings.port;

  preStartScript = import ./_db_check.nix {
    inherit pkgs;
    text = fileContents ./prestart_db_check.sh;
  };

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
      services.powerdns = {
        # secretsFile.shit = { path = "/tmp"; };

        debug = true;
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
        virtualInstances.default.extraPreStart =
          with config.services.powerdns.settings;
          ''
            ${preStartScript}/bin/dbcheck \
              --db-user ${gpgsql-user}\
              --db-host ${gpgsql-host}\
              --db-port ${gpgsql-port}
          '';
        virtualInstances.default.settings = {
          local-address = mkDefault "0.0.0.0";
          local-port = mkDefault "53";

          webserver-allow-from = "127.0.0.1";
          webserver-address = "127.0.0.1";
          webserver-port = "8081";

          dnsupdate = "yes";
          allow-dnsupdate-from = mkDefault "127.0.0.1/32";

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
