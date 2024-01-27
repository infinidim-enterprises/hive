{ inputs, cell, ... }:

{ config, self, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.postgresql;
  getAddr = a: head (splitString "/" (head lan.${a}.addresses).addressConfig.Address);
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  powerdns-admin-ip = getAddr "powerdns-admin";
  powerdns-ip = getAddr "dns-native";
  kea-ip = getAddr "kea-dhcp";
  namespace = "lan-" + lan.domain;
in

mkMerge [
  {
    containers."${namespace}-postgresql-dns-dhcp" = {
      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      bindMounts.postgresql-state.hostPath = "/persist/domains/${lan.domain}/postgresql";
      bindMounts.postgresql-state.mountPoint = "/var/lib/postgresql";
      bindMounts.postgresql-state.isReadOnly = false;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;
      config = { config, lib, pkgs, ... }:
        {
          imports = containers.systemd;
          networking.hostName = "postgresql-dns-dhcp";
          networking.domain = lan.domain;
          networking.firewall.allowedTCPPorts = [ 5432 ];
          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          # TODO: pg_dump --data-only --inserts --no-privileges --no-owner <DATABASE>
          systemd.services.postgresql = with config.services.postgresql; {
            preStart = lib.mkAfter ''
              [[ -e  "${dataDir}/.first_startup" ]] && touch "${dataDir}/.first_startup_user" || true
            '';
            postStart =
              let
                powerdnsSqlSetup = pkgs.writeText "powerdns-permissions.sql" ''
                  GRANT ALL ON domains               TO powerdns;
                  GRANT ALL ON domains_id_seq        TO powerdns;
                  GRANT ALL ON records               TO powerdns;
                  GRANT ALL ON records_id_seq        TO powerdns;
                  GRANT ALL ON domainmetadata        TO powerdns;
                  GRANT ALL ON domainmetadata_id_seq TO powerdns;
                  GRANT ALL ON comments              TO powerdns;
                  GRANT ALL ON comments_id_seq       TO powerdns;
                  GRANT ALL ON cryptokeys            TO powerdns;
                  GRANT ALL ON cryptokeys_id_seq     TO powerdns;
                  GRANT ALL ON tsigkeys              TO powerdns;
                  GRANT ALL ON tsigkeys_id_seq       TO powerdns;
                  GRANT SELECT ON supermasters       TO powerdns;
                '';
                keadhcpSqlSetup = pkgs.writeText "kea-permissions.sql" ''
                  GRANT ALL ON dhcp4_options        TO kea;
                  GRANT ALL ON dhcp6_options        TO kea;
                  GRANT ALL ON dhcp_option_scope    TO kea;
                  GRANT ALL ON host_identifier_type TO kea;
                  GRANT ALL ON hosts                TO kea;
                  GRANT ALL ON ipv6_reservations    TO kea;
                  GRANT ALL ON lease4               TO kea;
                  GRANT ALL ON lease4_stat          TO kea;
                  GRANT ALL ON lease6               TO kea;
                  GRANT ALL ON lease6_stat          TO kea;
                  GRANT ALL ON lease6_types         TO kea;
                  GRANT ALL ON lease_hwaddr_source  TO kea;
                  GRANT ALL ON lease_state          TO kea;
                  GRANT ALL ON logs                 TO kea;
                  GRANT ALL ON schema_version       TO kea;
                  GRANT ALL ON dhcp4_options_option_id_seq          TO kea;
                  GRANT ALL ON dhcp6_options_option_id_seq          TO kea;
                  GRANT ALL ON hosts_host_id_seq                    TO kea;
                  GRANT ALL ON ipv6_reservations_reservation_id_seq TO kea;
                  SET TIMEZONE = 'CET';
                '';
              in
              # FIXME: test credentials!
              lib.mkAfter ''
                if test -e "${dataDir}/.first_startup_user"; then
                  $PSQL -f "${pkgs.powerdns}/share/doc/pdns/schema.pgsql.sql" -d powerdns
                  $PSQL -f "${powerdnsSqlSetup}" -d powerdns
                  $PSQL -f "${pkgs.kea}/share/kea/scripts/pgsql/dhcpdb_create.pgsql" -d kea
                  $PSQL -f  ${keadhcpSqlSetup} -d kea
                  $PSQL -tAc "alter user kea password 'kea'"
                  $PSQL -tAc "alter user powerdns password 'powerdns'"
                  $PSQL -tAc "alter user powerdnsadmin password 'powerdnsadmin'"
                  rm -f "${dataDir}/.first_startup_user"
                fi
              '';
          };

          services.postgresql = {
            # NOTE: extraPlugins = [ pkgs.postgresql.pkgs.pg_ed25519 ];
            enable = true;
            enableTCPIP = true;
            # NOTE: must be set the same as on the machine running kea-dhcp
            # https://gitlab.isc.org/isc-projects/kea/-/issues/1731
            settings.timezone = "CET";
            settings.log_timezone = "CET";
            ensureDatabases = [ "powerdnsadmin" "powerdns" "kea" ];
            authentication = ''
              host all all 10.11.1.220/32 trust
              host kea kea ${kea-ip}/32 password
              host powerdns powerdns ${powerdns-ip}/32 password
              host powerdnsadmin powerdnsadmin ${powerdns-admin-ip}/32 password
            '';

            ensureUsers = [
              {
                name = "powerdnsadmin";
                ensurePermissions = { "DATABASE powerdnsadmin" = "ALL PRIVILEGES"; };
              }

              {
                name = "powerdns";
                ensurePermissions = { "DATABASE powerdns" = "ALL PRIVILEGES"; };
              }

              {
                name = "kea";
                ensurePermissions = { "DATABASE kea" = "ALL PRIVILEGES"; };
              }

            ];
          };

        };
    };

  }
]
