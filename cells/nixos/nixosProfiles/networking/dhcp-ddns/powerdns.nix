{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    types
    toInt
    mkMerge
    isNull
    toUpper
    toString
    mkOption
    mapAttrsToList
    optionalString
    mkEnableOption;

  psql_port = toString config.services.postgresql.settings.port;
  cfgDir = ''conf_dir=$(systemctl cat pdns.service | grep -i config-dir | awk -F ' ' '{printf $2}' | awk -F '=' '{printf $2}')'';
  param = ''--config-dir="''${conf_dir}" $@'';

  inherit (config.services.powerdns) zones;

  endpoint = { method, zone ? null, path ? null, apikey ? "testkey" }:
    "http --json ${method}" +
    " " +
    "http://localhost:8081/api/v1/servers/localhost/zones" +
    (optionalString (!isNull zone) "/${zone}.") +
    (optionalString (!isNull path) "/${path}") +
    " " +
    "X-API-Key:\\ ${apikey}";

  json = pkgs.formats.json { };

  recordOptions = { ... }: with types; {
    options = {
      content = mkOption { type = str; };
      disabled = mkEnableOption "isDisabled";
    };
  };

  rrsetOptions = { name, ... }: with types; {
    options = {
      ttl = mkOption {
        type = oneOf [ str int ];
        apply = x: toInt (toString x);
        default = 60;
      };

      type = mkOption {
        apply = x: toUpper x;
        type = enum [
          "A"
          "AAAA"
          "AFSDB"
          "ALIAS"
          "CAA"
          "CERT"
          "CDNSKEY"
          "CDS"
          "CNAME"
          "DNSKEY"
          "DNAME"
          "DS"
          "HINFO"
          "KEY"
          "LOC"
          "MX"
          "NAPTR"
          "NS"
          "NSEC"
          "NSEC3"
          "NSEC3PARAM"
          "OPENPGPKEY"
          "PTR"
          "RP"
          "RRSIG"
          "SOA"
          "SPF"
          "SSHFP"
          "SRV"
          "TKEY, TSIG"
          "TLSA"
          "SMIMEA"
          "TXT"
          "URI"
        ];
      };
      name = mkOption {
        type = nullOr str;
        apply = x:
          if isNull x
          then "${name}."
          else "${x}.${name}.";
        default = null;
      };
      changetype = mkOption {
        type = enum [ "replace" "delete" ];
        default = "replace";
      };
      records = mkOption { type = listOf (submodule [ recordOptions ]); };
    };
  };

  zoneOptions = { name, ... }: with types; {
    options = {
      dnssec = mkEnableOption "DNSSEC" // { default = true; };
      rrsets = mkOption { type = listOf (submodule [ (rrsetOptions { inherit name; }) ]); };
      initScript = mkOption {
        readOnly = true;
        default = pkgs.writeShellApplication {
          name = "initzone-${name}";
          runtimeInputs = with pkgs;[ httpie ];
          text = ''
            # create ${name} zone
            ${endpoint { method = "POST"; }} < ${json.generate "zone_${name}_.json" {
              name = "${name}.";
              kind = "Native";
              masters = [];
              nameservers = [ "ns1.${name}." ];
            }}

            ${endpoint { method = "PATCH"; }} < ${json.generate "zone_${name}_records.json" zones."${name}".rrsets}
          '';
        };
      };
    };
  };

in
{
  options.services.powerdns = with types; {
    zones = mkOption {
      description = "dns zones";
      type = attrsOf (submodule [ zoneOptions ]);
    };
  };


  config = mkMerge [
    {
      # networking.firewall.interfaces."njk.local".allowedUDPPorts = [ 5353 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      # dogdns
      environment.systemPackages =
        (mapAttrsToList (n: v: v.initScript) config.services.powerdns.zones) ++
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

      systemd.services.pdns.path = with pkgs; [ libressl.nc ];
      systemd.services.pdns.preStart = ''
        until nc -d -z 127.0.0.1 ${psql_port};do echo 'waiting for sql server for 5 sec.' && sleep 5;done
      '';

      services.powerdns = {
        enable = true;
        # default-soa-name=njk.local <- removed with upgrade
        # FIXME: https://docs.powerdns.com/authoritative/settings.html#setting-default-soa-content

        # FIXME: test credentials!
        # TODO: secretFile = sops.secrets.powerdns.path;
        extraConfig = ''
          local-address=0.0.0.0:5353

          webserver-allow-from=127.0.0.1
          webserver-address=127.0.0.1

          dnsupdate=yes
          allow-dnsupdate-from=127.0.0.1/32

          default-ttl=60
          dnssec-key-cache-ttl=0

          api=yes
          api-key=testkey

          version-string=full

          launch=gpgsql
          gpgsql-host=127.0.0.1
          gpgsql-port=${psql_port}
          gpgsql-user=powerdns
          gpgsql-dbname=powerdns
          gpgsql-dnssec=yes
        '';
        /*

          soa-refresh-default=10800
          soa-retry-default=3600
          soa-expire-default=604800
          soa-minimum-ttl=60

        */
      };
    }
  ];
}
