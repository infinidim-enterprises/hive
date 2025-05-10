{ inputs, cell, ... }:

{ self, config, lib, pkgs, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.kea-dhcp;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  localAddressSuffix = last (splitString "." localAddress);

  # dhcpServerAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  tftpIp = head (splitString "/" (head (lan.tftp-server.addresses)).addressConfig.Address);
  httpIp = head (splitString "/" (head (lan.http-server.addresses)).addressConfig.Address);
  dnsMasterIp = head (splitString "/" (head (lan.dns-native.addresses)).addressConfig.Address);
  postgresqlIp = head (splitString "/" (head (lan.postgresql.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
  sameHost = hasAttrByPath [ "containers" "postgresql-dns-dhcp" ] config;

  hosts-database = {
    type = "postgresql";
    name = "kea";
    host = postgresqlIp;
    port = 5432;
    user = "kea";
    password = "kea";
    lfc-interval = 3600;
    max-reconnect-tries = 10;
    reconnect-wait-time = 600000;
  };

in

mkMerge [
  (mkIf true {

    age.secrets."zerotier-${namespace}-dhcp-boot-server" = {
      file = "${self}/secrets/containers/lan/dhcp-boot-server/zt-key.age";
      mode = "0600";
      path = "/run/secrets/dhcp-boot-server-zt.identity.secret";
    };

    containers."${namespace}-dhcp-boot-server" = {
      enableTun = true;

      bindMounts.zerotier-id.hostPath = "/run/secrets/dhcp-boot-server-zt.identity.secret";
      bindMounts.zerotier-id.mountPoint = "/var/lib/zerotier-one/identity.secret";
      bindMounts.zerotier-id.isReadOnly = true;

      config = {
        imports = [ self.nixosModules.kea-vpn-bridge ];
        services.kea = { inherit (cfg) vpn-bridges; };
      };
    };
  })

  (mkIf sameHost {
    # This is likely not required, we're depdning on connectivity directly.
    systemd.services."container@${namespace}-powerdns-native" = {
      after = [
        "container@${namespace}-postgresql-dns-dhcp.service"
        "container@${namespace}-powerdns-native.service"
      ];
      partOf = [
        "container@${namespace}-postgresql-dns-dhcp.service"
        "container@${namespace}-powerdns-native.service"
      ];
    };
  })

  #    {
  # NOTE: https://hicu.be/bridge-vs-macvlan
  # NOTE: https://github.com/networkboot/docker-dhcpd/issues/25
  # https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking#macvtap_ipvtap
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-virtual_networking-directly_attaching_to_physical_interface
  # ISSUE: unable to set macvlan to allow broadcasts.

  {
    containers."${namespace}-dhcp-boot-server" = {

      additionalCapabilities = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_BROADCAST"
        "CAP_NET_RAW"
      ];

      inherit (lan) macvlans;
      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;
      extraFlags = [ "--tmpfs=/run/kea" ];

      config = { pkgs, ... }:
        {
          imports = containers.systemd;

          networking.hostName = "dhcp-boot-server";
          networking.domain = lan.domain;
          networking.firewall.allowedUDPPorts = [ 67 ];

          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          systemd.services.kea-dhcp4-server.path = with pkgs; [ libressl.nc ];
          systemd.services.kea-dhcp4-server.preStart = ''
            until nc -d -z ${postgresqlIp} 5432;do echo 'waiting for sql server for 5 sec.' && sleep 5;done
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
              inherit (cfg.dhcp-ddns) forward-ddns reverse-ddns;
            };
          };

          services.kea.dhcp4 = {
            enable = true;

            settings = {
              inherit (cfg) subnet4;
              inherit hosts-database;
              lease-database = hosts-database;

              ### NOTE: https://gist.github.com/robinsmidsrod/4008017
              ### https://gist.github.com/NiKiZe/5c181471b96ac37a069af0a76688944d
              ### https://github.com/pashinin/kea-docker-image/blob/b00aeef49fa5398060f995f930bebe9099b6c7bd/kea-dhcp4.conf
              option-def = import ./_dhcp-opts-ipxe.nix;
              client-classes = import ./_dhcp-classes-ipxe.nix { inherit cfg lib httpIp tftpIp lan; };

              interfaces-config.dhcp-socket-type = "raw";
              interfaces-config.interfaces = lan.macvlans;

              # 72h * 60 * 60
              valid-lifetime = 3600;
              renew-timer = 3600;
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

              loggers = let pattern = "%d{%j %H:%M:%S.%q} %c %m\n"; in
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

        };
    };

  }
]
