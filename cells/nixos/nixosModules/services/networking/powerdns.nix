{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.powerdns;
  configFormat = pkgs.formats.keyValue { };
  json = (pkgs.formats.json { }).generate;
  mkIni = configFormat.generate;

  backendConn = setts:
    let
      host = findFirst (e: e == "${setts.launch}-host") null (attrNames setts);
      port = findFirst (e: e == "${setts.launch}-port") null (attrNames setts);
    in
    if (isNull port || isNull host)
    then throw "Please specify both powerdns backend host and port, eg. { gpgsql-port = 5432; gpgsql-host = localhost; }"
    else {
      host = setts.${host};
      port = setts.${port};
    };

  ini2jsonJQ = pkgs.writeText "ini2jsonJQ" ''
    def sectionToEntry:
      split("\n")
        | map(select(length>0))
        | {
          (.[0]): .[1:] | map(
              split("=") | { key: .[0], value:.[1] }
            ) | from_entries
        }
    ;

    def formatSection:
      if startswith("[") and endswith("]") then
        ["\f", .]|join("")  # separator + section name
      else
        .|gsub("\\s*=\\s*"; "=")  # section values
      end
    ;

    split("\n")
    | ["\fglobal", .[]|formatSection]
    | join("\n")
    | split("\f")
    | map(select(length > 0) | sectionToEntry)
    | reduce .[] as $x ({}; . + $x)
    | if .global == {} then del(.global) else . end
  '';

  ini2json = pkgs.writeShellApplication {
    name = "ini2json";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      jq -R -s -f ${ini2jsonJQ} < "$1"
    '';
  };

  endpoint = { method, zone ? null, path ? null }:
    "http --json ${method}" +
    " " +
    ''http://"''${APIHOST}":"''${APIPORT}"/api/v1/servers/localhost/zones'' +
    (optionalString (!isNull zone) "/${zone}.") +
    (optionalString (!isNull path) "/${path}") +
    " " +
    ''X-API-Key:\ "'${"$"}{APIKEY}'"'';

  initZone = { name, zone }:
    pkgs.writeShellApplication {
      excludeShellChecks = [ "SC2154" "SC2002" ];
      name = "initzone-${name}";
      runtimeInputs = with pkgs; [ httpie gawk coreutils ];
      text =
        let
          deleteZone = ''
            # delete zone
            ${endpoint { method = "DELETE"; zone = name; }}
          '';
          dnssecString = ''
            # enable dnssec
            ${endpoint { method = "POST"; zone = name; path = "cryptokeys"; }} < ${json "zone_${name}_ddns_secure.json" {
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
        ''
          ${optionalString (! zone.mutable) deleteZone}

          # create zone
          ${endpoint { method = "POST"; }} < ${json "zone_${name}_.json" {
            name = "${name}.";
            kind = "Native";
            masters = [];
          }}

          # Setup metadata
          ${endpoint { method = "PUT"; zone = name; path = "metadata/SOA-EDIT"; }} < ${json "zone_${name}_soa-edit.json" { metadata = ["INCREASE"]; }}
          ${endpoint { method = "PUT"; zone = name; path = "metadata/SOA-EDIT-DNSUPDATE"; }} < ${json "zone_${name}_soa-edit-dnsupdate.json" { metadata = ["INCREASE"]; }}

          # create records
          ${endpoint { method = "PATCH"; zone = name; }} < ${json "zone_${name}_records.json" { inherit (zone) rrsets; }}

          ${optionalString zone.dnssec dnssecString}
        '';
    };

  recordOptions = { ... }:
    with types; {
      options = {
        content = mkOption { type = str; };
        disabled = mkEnableOption "isDisabled";
      };
    };

  rrsetOptions = { name, ... }:
    with types; {
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

  zoneOptions = { name, ... }:
    with types; {
      options = {
        dnssec = mkEnableOption "DNSSEC" // { default = true; };
        mutable = mkEnableOption "Allow manual modification" //
          { default = false; };
        rrsets = mkOption {
          type = listOf (submodule [ (rrsetOptions { inherit name; }) ]);
        };
      };
    };

  virtualInstanceOptions = { ... }:
    with types; {
      options = {
        enable = mkEnableOption "PowerDNS domain name server";
        settings = mkOption {
          default = null;
          type = nullOr configFormat.type;
        };

        secretsFile = mkOption {
          type = nullOr path;
          default = null;
          example = "/run/keys/powerdns.env";
          description = ''
            Values will be appended to config.
            cat configFile secretsFile > finalConfig
          '';
        };

        zones = mkOption {
          description = "dns zones";
          type = attrsOf (submodule [ zoneOptions ]);
        };
      };
    };
in
{
  imports = [{ disabledModules = [ "services/networking/powerdns.nix" ]; }];

  options = {
    services.powerdns = with types; {
      enable = mkEnableOption "PowerDNS domain name server" // {
        readOnly = true;
        default = (filterAttrs (_: v: v.enable) cfg.virtualInstances) != { };
      };
      virtualInstances = mkOption {
        type = nullOr (attrsOf (submodule [ virtualInstanceOptions ]));
      };
      settings = mkOption {
        type = nullOr configFormat.type;
        default = null;
        description = ''
          Global settings for all virtual instances.
          Will be overwritten by instance settings.
        '';
      };
      # secretsFile = mkOption {
      #   type = nullOr (submodule [ secretsFileOptions ]);
      #   default = null;
      #   description = ''
      #     Global secrets for all virtual instances.
      #     Will be overwritten by instance secretsFile.
      #   '';
      # };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion =
            (filter (e: hasInfix "-" e)
              (attrNames cfg.virtualInstances))
            == [ ];
          message = "PowerDNS virtual instance names must not include a '-' (dash) character";
        }

        {
          assertion =
            let
              settsList = [ cfg.settings ] ++ (mapAttrsToList (n: v: v.settings) cfg.virtualInstances);
              settsWithLaunch = filter (e: hasAttr "launch" e) settsList;
            in
            (filter (e: hasInfix "," e.launch) settsWithLaunch) == [ ];
          message = "This module does not support launching multiple backends, please use only 1, eg. launch=gpgsql";
        }
      ];
    }

    {
      systemd.packages = [ pkgs.pdns ];

      users.groups.pdns = { };
      users.users.pdns.isSystemUser = true;
      users.users.pdns.group = "pdns";
      users.users.pdns.description = "PowerDNS";
    }

    {
      systemd.services = ({
        pdns.enable = false;

        "pdns@".path = with pkgs; [ ini2json jq libressl.nc ];
        "pdns@".environment.confDir = "/run/pdns";
        "pdns@".serviceConfig.ExecStart = [
          "" # Override
          (concatStringsSep " " [
            "${pkgs.pdns}/bin/pdns_server"
            "--config-name=%i"
            "--config-dir=/run/pdns"
            "--guardian=no"
            "--daemon=no"
            "--disable-syslog"
            "--log-timestamp=no"
            "--write-pid=no"
          ])
        ];
      }) // mapAttrs'
        (n: v:
          let
            cfgName = "pdns-${n}.conf";
          in
          nameValuePair "pdns@${n}"
            {
              # overrideStrategy = "asDropin";

              wantedBy = [ "multi-user.target" ];

              after = [
                "network.target"
                "mysql.service"
                "postgresql.service"
                "openldap.service"
              ];

              preStart =
                let
                  inherit (backendConn (cfg.settings // v.settings)) host port;
                  cfgString = concatStringsSep " " (
                    [ "cat" ] ++
                      (optional (!isNull cfg.settings) "${mkIni "pdns.conf" cfg.settings}") ++
                      (optional (!isNull v.settings) "${mkIni cfgName v.settings}") ++
                      # FIXME: (optional (!isNull cfg.secretsFile) "${cfg.secretsFile}") ++
                      (optional (!isNull v.secretsFile) "${v.secretsFile}") ++
                      [ ''> "''${confDir}/${cfgName}"'' ]
                  );
                in
                concatStringsSep "\n"
                  [
                    ''mkdir -p "''${confDir}"''
                    "until nc -d -z ${host} ${port};do echo 'waiting for backend for 5 sec.' && sleep 5;done"
                    cfgString
                  ];

              postStart =
                let
                  host = (cfg.settings // v.settings).webserver-address;
                  port = v.settings.webserver-port;
                in
                concatStringsSep "\n"
                  ([ ''export APIKEY=$(ini2json "''${confDir}/${cfgName}" | jq -r '.global."api-key"')'' ] ++
                    [ ''export APIHOST=${host}'' ] ++
                    [ ''export APIPORT=${port}'' ] ++
                    (mapAttrsToList
                      (name: zone:
                        "${initZone { inherit name zone; }}/bin/initzone-${name}")
                      v.zones));
            })
        cfg.virtualInstances;
    }
  ]);
}
