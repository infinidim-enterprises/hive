{ inputs, cell, ... }:

{ config, pkgs, lib, ... }:
with lib;

let
  inherit (lib // builtins)
    concatMapStringsSep
    mkAfter
    mkForce
    map;

  inherit (pkgs) writeText;

  powerdnsSqlSetup = writeText "powerdns-permissions.sql"
    ((concatMapStringsSep "\n"
      (s: "GRANT ALL ON" + " " + s + " " + "TO powerdns;")
      [
        "domains"
        "domains_id_seq"
        "records"
        "records_id_seq"
        "domainmetadata"
        "domainmetadata_id_seq"
        "comments"
        "comments_id_seq"
        "cryptokeys"
        "cryptokeys_id_seq"
        "tsigkeys"
        "tsigkeys_id_seq"
      ]) + "\n" + "GRANT SELECT ON supermasters TO powerdns;" + "\n");

  keadhcpSqlSetup = writeText "kea-permissions.sql"
    ((concatMapStringsSep "\n"
      (s: "GRANT ALL ON" + " " + s + " " + "TO kea;")
      [
        "dhcp4_options"
        "dhcp6_options"
        "dhcp_option_scope"
        "host_identifier_type"
        "hosts"
        "ipv6_reservations"
        "lease4"
        "lease4_stat"
        "lease6"
        "lease6_stat"
        "lease6_types"
        "lease_hwaddr_source"
        "lease_state"
        "logs"
        "schema_version"
        "dhcp4_options_option_id_seq"
        "dhcp6_options_option_id_seq"
        "hosts_host_id_seq"
        "ipv6_reservations_reservation_id_seq"
      ]) + "\n" + "SET TIMEZONE = 'CET';" + "\n");
in
{
  config = mkMerge [
    {
      systemd.services.postgresql = with config.services.postgresql; {
        preStart = mkAfter ''
          [[ -e  "${dataDir}/.first_startup" ]] && touch "${dataDir}/.first_startup_user" || true
        '';
        postStart =
          mkAfter ''
            if test -e "${dataDir}/.first_startup_user"; then
              $PSQL --tuples-only --no-align --dbname=powerdns --command='ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO powerdns'
              $PSQL --host=127.0.0.1 --no-password --username=powerdns --dbname=powerdns --file="${pkgs.powerdns}/share/doc/pdns/schema.pgsql.sql"

              $PSQL --tuples-only --no-align --dbname=kea --command='ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO kea'
              $PSQL --host=127.0.0.1 --no-password --username=kea --dbname=kea --file="${pkgs.kea}/share/kea/scripts/pgsql/dhcpdb_create.pgsql"

              rm -f "${dataDir}/.first_startup_user"
            fi
          '';

        # $PSQL -f "${powerdnsSqlSetup}" -d powerdns
        # $PSQL -f  ${keadhcpSqlSetup} -d kea
        # $PSQL -tAc "alter user kea password 'kea'"
        # $PSQL -tAc "alter user powerdns password 'powerdns'"

      };

      services.postgresql = {
        # TODO: maybe use .initialScript
        enable = true;
        enableTCPIP = true;
        extensions = [ pkgs.postgresql.pkgs.pg_ed25519 ];

        # NOTE: must be set the same as on the machine running kea-dhcp
        # https://gitlab.isc.org/isc-projects/kea/-/issues/1731
        settings.timezone = "CET";
        settings.log_timezone = "CET";
        # settings.log_destination = "syslog";

        authentication = mkForce ''
          local all all trust
          host all all 127.0.0.1/32 trust
          # host all all localhost trust
        '';

        ensureDatabases = [ "powerdns" "kea" ];
        ensureUsers = map
          (user: {
            name = user;
            ensureDBOwnership = true;
            ensureClauses.login = true;
            ensureClauses."inherit" = true;
          })
          config.services.postgresql.ensureDatabases;
      };
    }
  ];
}
