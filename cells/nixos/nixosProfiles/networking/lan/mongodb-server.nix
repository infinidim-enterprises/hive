{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.mongodb-server;
  # localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
  pPath = "/persist/domains/${lan.domain}/mongodb";
in

mkMerge [
  {
    system.activationScripts."${namespace}-mongodb-server-dbpath" = ''
      [[ ! -d ${pPath} ]] && mkdir -p ${pPath} || true
      chown --recursive 10000:27017 ${pPath}
    '';
  }

  {
    containers."${namespace}-mongodb-server" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      bindMounts.mongodb-state.hostPath = pPath;
      bindMounts.mongodb-state.mountPoint = "/var/lib/mongodb";
      bindMounts.mongodb-state.isReadOnly = false;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      config =
        {
          imports = containers.systemd;

          networking.hostName = "mongodb-server";
          networking.domain = lan.domain;
          networking.firewall.allowedTCPPorts = [ 27017 27018 27019 ];

          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          users.users.mongodb.uid = 10000;
          users.groups.mongodb.gid = 27017;

          services.mongodb.enable = true;
          services.mongodb.dbpath = "/var/lib/mongodb";
          services.mongodb.bind_ip = "0.0.0.0";
        };
    };

  }
]
