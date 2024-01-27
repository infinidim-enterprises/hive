{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.graylog-server;
  # localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  esIP = head (splitString "/" (head (lan.elasticsearch-server.addresses)).addressConfig.Address);
  mongodbIP = head (splitString "/" (head (lan.mongodb-server.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
  pPath = "/persist/domains/${lan.domain}/graylog";
  # ids = with builtins; (toString config.ids.uids.graylog) + ":" + (toString config.ids.gids.graylog);
in

mkMerge [
  {
    system.activationScripts."${namespace}-graylog-server-dataDir" = ''
      [[ ! -d ${pPath} ]] && mkdir -p ${pPath} || true
      chown --recursive 10000:12201 ${pPath}
    '';
  }

  {
    containers."${namespace}-graylog-server" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      bindMounts.graylog-state.hostPath = pPath;
      bindMounts.graylog-state.mountPoint = "/var/lib/graylog";
      bindMounts.graylog-state.isReadOnly = false;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      config = { pkgs, ... }:
        {
          imports = containers.systemd;

          networking.hostName = "graylog-server";
          networking.domain = lan.domain;
          networking.firewall.allowedTCPPorts = [ 9000 12201 ];

          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          systemd.services.graylog.path = [ pkgs.libressl.nc ];
          systemd.services.graylog.preStart = ''
            until nc -z ${esIP} 9200; do sleep 3; done
            until nc -z ${mongodbIP} 27017; do sleep 3; done
          '';

          users.users.graylog.uid = 10000;
          users.groups.graylog.gid = 12201;
          # --no-pid-file
          systemd.services.graylog.environment.GRAYLOG_PID = "/var/lib/graylog/graylog.pid";
          systemd.services.graylog.environment.JAVA_OPTS = "-Xms512M -Xmx512M";
          services.graylog.enable = true;
          services.graylog.mongodbUri = "mongodb://${mongodbIP}:27017/graylog";
          services.graylog.plugins = with pkgs.graylogPlugins; [
            jabber
            metrics
            integrations
            dnsresolver
            aggregates
            auth_sso
            pagerduty
            slack
            snmp
          ];

          ### FIXME: default credentials
          ### echo -n "admin" | shasum -a 256
          services.graylog.passwordSecret = "9csIhz3DQmqAfiijOFyStn4S1TVdIllZwuKqlZ9C0va8kDXJhxIZnvCEPmdckgMFOHWRDZDE50BFhtBcAplc8RHpi1lTu65d";
          services.graylog.rootPasswordSha2 = "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918";
          services.graylog.elasticsearchHosts = [ "http://${esIP}:9200" ];
        };
    };

  }
]
