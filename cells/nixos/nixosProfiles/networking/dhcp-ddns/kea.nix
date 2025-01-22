{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    hasAttr
    mkMerge
    toString
    optionalString
    fileContents;

  hosts-database = {
    type = "postgresql";
    name = "kea";
    host = "127.0.0.1";
    port = 5432;
    user = "kea";
    # password = "kea";
    lfc-interval = 3600;
    max-reconnect-tries = 10;
    reconnect-wait-time = 600000;
  };

  preStartScript = import ./_db_check.nix {
    inherit pkgs;
    text = fileContents ./prestart_db_check.sh;
  };

in
{
  config = mkMerge [
    {
      systemd.services.kea-dhcp4-server.path = [ preStartScript ];
      systemd.services.kea-dhcp4-server.preStart = ''
        dbcheck \
          --db-user ${hosts-database.user} \
          --db-host ${hosts-database.host} \
          --db-port ${toString hosts-database.port} ${optionalString
            (hasAttr "password" hosts-database)
            "--db-password ${hosts-database.password}"}
      '';

      systemd.services.kea-dhcp4-server.serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BROADCAST" ];
        CapabilityBoundingSet = [ "CAP_NET_BROADCAST" ];
      };

      services.kea.dhcp-ddns = {
        enable = true;
        settings = {
          ip-address = "127.0.0.1";
          port = 53001;
        };
      };

      services.kea.dhcp4 = {
        enable = true;

        settings = {
          inherit hosts-database;
          lease-database = hosts-database;

          ### NOTE: https://gist.github.com/robinsmidsrod/4008017
          ### https://gist.github.com/NiKiZe/5c181471b96ac37a069af0a76688944d
          ### https://github.com/pashinin/kea-docker-image/blob/b00aeef49fa5398060f995f930bebe9099b6c7bd/kea-dhcp4.conf
          option-def = import ./_dhcp-opts-ipxe.nix;
          # TODO: client-classes = import ./_dhcp-classes-ipxe.nix { inherit cfg lib httpIp tftpIp lan; }; # iPXE booting

          interfaces-config.dhcp-socket-type = "raw";
          # interfaces-config.interfaces = lan.macvlans; # Physical

          # 72h * 60 * 60
          valid-lifetime = 3600; # 1 hour
          renew-timer = 3600; # 1 hour
          # rebind-timer = 1800;

          multi-threading = {
            enable-multi-threading = true;
            thread-pool-size = 4;
            packet-queue-size = 64;
          };

          ### NOTE: https://kea.readthedocs.io/en/kea-2.0.1/arm/lease-expiration.html?highlight=valid-lifetime
          expired-leases-processing = {
            reclaim-timer-wait-time = 10;
            flush-reclaimed-timer-wait-time = 25;
            hold-reclaimed-time = 120;
            max-reclaim-leases = 100;
            max-reclaim-time = 250;
            unwarned-reclaim-cycles = 5;
          };

          loggers =
            let
              pattern = "%d{%j %H:%M:%S.%q} %c %m\n";
            in
            [
              {
                name = "kea-dhcp4";
                output_options = [{ output = "stdout"; inherit pattern; }];
                severity = "INFO";
              }
            ];

          dhcp-ddns = {
            enable-updates = true;
            server-ip = "127.0.0.1";
            server-port = 53001;
            # sender-ip = "";
            # sender-port = 0;
            max-queue-size = 1024;
            ncr-protocol = "UDP";
            ncr-format = "JSON";
          };

          # Global and per subnet options
          ddns-override-client-update = true;
          ddns-override-no-update = true;
          ddns-replace-client-name = "when-not-present"; # never
          hostname-char-set = "[^A-Za-z0-9.-]";
          hostname-char-replacement = "-";
        };
      };
    }
  ];
}
