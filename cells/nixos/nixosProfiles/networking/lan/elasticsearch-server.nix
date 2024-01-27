{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.elasticsearch-server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
  pPath = "/persist/domains/${lan.domain}/elasticsearch";
  ids = with builtins; (toString config.ids.uids.elasticsearch) + ":" + (toString config.ids.gids.elasticsearch);
in

mkMerge [
  {
    system.activationScripts."${namespace}-elasticsearch-server-dataDir" = ''
      [[ ! -d ${pPath} ]] && mkdir -p ${pPath} || true
      chown --recursive ${ids} ${pPath}
    '';
  }

  {
    containers."${namespace}-elasticsearch-server" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      bindMounts.elasticsearch-state.hostPath = pPath;
      bindMounts.elasticsearch-state.mountPoint = "/var/lib/elasticsearch";
      bindMounts.elasticsearch-state.isReadOnly = false;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      config = { pkgs, lib, ... }:
        {
          imports = containers.systemd;

          networking.hostName = "elasticsearch-server";
          networking.domain = lan.domain;
          networking.firewall.allowedTCPPorts = [ 9200 9300 ];

          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          # systemd.services.elasticsearch.postStart = lib.mkForce ''
          #   echo 'WTF!!!! This should have worked!'
          #   ${pkgs.libressl.nc}/bin/nc -z ${localAddress} 9200 || true
          # '';

          # services.elasticsearch.enable = true;
          # services.elasticsearch.package = pkgs.elasticsearch-oss;
          # services.elasticsearch.extraConf = ''
          #   network.publish_host: 127.0.0.1
          #   network.bind_host: 127.0.0.1
          # '';

          services.elasticsearch.enable = true;
          services.elasticsearch.dataDir = "/var/lib/elasticsearch";
          services.elasticsearch.port = 9200;
          services.elasticsearch.tcp_port = 9300;
          services.elasticsearch.listenAddress = localAddress;
          services.elasticsearch.package = pkgs.elasticsearch7; # pkgs.elasticsearch-oss;
          services.elasticsearch.extraJavaOptions = [
            "-Djava.net.preferIPv4Stack=true"
            "-Des.http.cname_in_publish_address=true"
            "-Xms512M"
            "-Xmx512M"
          ];
          services.elasticsearch.logging = ''
            logger.action.name = org.elasticsearch.action
            logger.action.level = info

            appender.console.type = Console
            appender.console.name = console
            appender.console.layout.type = PatternLayout
            appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

            rootLogger.level = info
            rootLogger.appenderRef.console.ref = console
          '';

          services.elasticsearch.extraConf = ''
            network.publish_host: ${localAddress}
            network.bind_host: ${localAddress}
          '';

        };
    };

  }
]
