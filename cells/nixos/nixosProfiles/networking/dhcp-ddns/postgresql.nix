{ inputs, cell, ... }:

{ config, pkgs, lib, ... }:
with lib;

let
  inherit (lib // builtins)
    concatMapStringsSep
    mapAttrsToList
    flatten
    mkAfter
    mkForce
    imap0
    map;

  init_done = ''
    $PSQL --host=127.0.0.1 --no-password --username=postgres --dbname=postgres \
      --command='create table if not exists init_done ( id SERIAL primary key )' \
      --command='GRANT SELECT ON init_done TO kea, powerdns'
  '';

  init_databases = concatStringsSep "\n" (imap0
    (i: s: if i > 0 then "  ${s}" else s)
    (flatten (mapAttrsToList
      (n: v:
        let
          psql = "$PSQL --host=127.0.0.1 --no-password --username=${n} --dbname=${n}";
          cmd = "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${n}";
        in
        [ "${psql} --file=\"${v}\"" "${psql} --command='${cmd}'" ])
      {
        powerdns = "${pkgs.powerdns}/share/doc/pdns/schema.pgsql.sql";
        kea = "${pkgs.kea}/share/kea/scripts/pgsql/dhcpdb_create.pgsql";
      })));

in
{
  # TODO: https://github.com/mittwald/brudi
  config = mkMerge [
    {
      systemd.services.postgresql = with config.services.postgresql; {
        preStart = mkAfter ''
          if test -e "${dataDir}/.first_startup"; then
            touch "${dataDir}/.first_startup_user"
          fi
        '';
        postStart =
          mkAfter ''
            if test -e "${dataDir}/.first_startup_user"; then

              ${init_databases}

              ${init_done}
              rm -f "${dataDir}/.first_startup_user"
            fi
          '';
        # $PSQL -tAc "alter user kea password 'kea'"
        # $PSQL -tAc "alter user powerdns password 'powerdns'"
      };

      time.timeZone = mkForce "CET";
      services.postgresql = {
        # TODO: maybe use .initialScript
        enable = true;
        enableTCPIP = true;
        extensions = [ pkgs.postgresql.pkgs.pg_ed25519 ];

        # NOTE: must be set the same as on the machine running kea-dhcp
        # https://gitlab.isc.org/isc-projects/kea/-/issues/1731
        settings.timezone = "CET";
        settings.log_timezone = "CET";

        authentication = mkForce ''
          local all all trust
          host all all 127.0.0.1/32 trust
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
