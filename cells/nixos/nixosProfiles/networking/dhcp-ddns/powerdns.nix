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
          "TKEY"
          "TSIG"
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
          else
          # NOTE: allow verbatim settings
            if hasSuffix "." x
            then x
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
      mutable = mkEnableOption "Allow manual modification" // { default = false; };
      rrsets = mkOption { type = listOf (submodule [ (rrsetOptions { inherit name; }) ]); };
      initScript = mkOption {
        readOnly = true;
        default = pkgs.writeShellApplication {
          excludeShellChecks = [ "SC2154" "SC2002" ];
          name = "initzone-${name}";
          runtimeInputs = with pkgs;[ httpie gawk coreutils ];
          text =
            let
              deleteZone = ''
                # delete zone
                ${endpoint { method = "DELETE"; zone = name; }}
              '';
              dnssecString = ''
                # enable dnssec
                ${endpoint { method = "POST"; zone = name; path = "cryptokeys"; }} < ${json.generate "zone_${name}_ddns_secure.json" {
                  type = "Cryptokey";
                  keytype = "csk";
                  active = true;
                  published = true;
                  algorithm = "ECDSAP256SHA256";
                  bits = 256;
                }}
                # rectify dnssec
                ${endpoint { method = "PUT"; zone = name; path = "rectify"; }}
              '';
            in
            # TODO: apikey=$(cat ${config.sops.secrets.powerdns.path} | awk -F'=' '{print $2}')
            ''
              ${optionalString (! zones."${name}".mutable) deleteZone}
              # create ${name} zone
              ${endpoint { method = "POST"; }} < ${json.generate "zone_${name}_.json" {
                name = "${name}.";
                kind = "Native";
                masters = [];
              }}
              # create records
              ${endpoint { method = "PATCH"; zone = name; }} < ${json.generate "zone_${name}_records.json" { inherit (zones."${name}") rrsets; }}
              ${optionalString zones."${name}".dnssec dnssecString}
              ${endpoint { method = "PUT"; zone = name; path = "metadata/SOA-EDIT"; }} < ${json.generate "zone_${name}_soa-edit.json" { metadata = ["INCREASE"]; }}
              ${endpoint { method = "PUT"; zone = name; path = "metadata/SOA-EDIT-DNSUPDATE"; }} < ${json.generate "zone_${name}_soa-edit-dnsupdate.json" { metadata = ["INCREASE"]; }}
            '';
        };
      };
    };
  };

  configFile = pkgs.writeText "pdns.conf" "${config.services.powerdns.extraConfig}";

  powerdnsStartScript = pkgs.writeShellApplication {
    runtimeInputs = [ pkgs.coreutils ];
    name = "pdns";
    text = ''
      mkdir -p /run/pdns
      cat ${configFile} ${config.sops.secrets.powerdns.path} > /run/pdns/pdns.conf
      exec ${pkgs.pdns}/bin/pdns_server --config-dir=/run/pdns --guardian=no --daemon=no --disable-syslog --log-timestamp=no --write-pid=no
    '';
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
    # (mkIf (hasAttrByPath [ "sops" "secrets" ] config) {
    #   sops.secrets.powerdns = {
    #     sopsFile = ../../../../secrets/sops/powerdns;
    #     restartUnits = [ "pdns.service" ];
    #     format = "binary";
    #   };
    # })

    {
      # networking.firewall.interfaces."njk.local".allowedUDPPorts = [ 5353 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

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

      systemd.services.pdns.path = [ pkgs.libressl.nc ];
      systemd.services.pdns.preStart = ''
        until nc -d -z 127.0.0.1 ${psql_port};do echo 'waiting for sql server for 5 sec.' && sleep 5;done
      '';

      # systemd.services.pdns.serviceConfig.ExecStart = mkForce "${powerdnsStartScript}/bin/pdns";

      systemd.services.pdns.postStart = concatStrings
        (mapAttrsToList
          (n: v: "${v.initScript}/bin/${v.initScript.name}\n")
          config.services.powerdns.zones);

      services.powerdns = {
        enable = true;
        extraConfig = ''
          local-address=0.0.0.0:5353

          api=yes
          api-key=testkey

          webserver-allow-from=127.0.0.1
          webserver-address=127.0.0.1

          dnsupdate=yes
          allow-dnsupdate-from=127.0.0.1/32

          default-soa-edit=increase
          default-api-rectify=yes
          default-ttl=60
          dnssec-key-cache-ttl=0

          version-string=full

          launch=gpgsql
          gpgsql-host=127.0.0.1
          gpgsql-port=${psql_port}
          gpgsql-user=powerdns
          gpgsql-dbname=powerdns
          gpgsql-dnssec=yes
        '';


        # api-key=testkey

      };
    }
  ];
}
