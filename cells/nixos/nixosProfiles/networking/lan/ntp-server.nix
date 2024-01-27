{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.ntp-server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
in

mkMerge [{
  containers."${namespace}-ntp-server" = {
    additionalCapabilities = [
      "CAP_NET_BIND_SERVICE"
      "CAP_SYS_RESOURCE"
      "CAP_SYS_TIME"
    ];
    inherit (lan) macvlans;

    timeoutStartSec = "120s";
    autoStart = true;
    ephemeral = true;

    config =
      {
        imports = containers.systemd;

        networking.hostName = "ntp-server";
        networking.domain = lan.domain;
        networking.firewall.allowedUDPPorts = [ 123 ];

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        services.openntpd.enable = true;
        services.openntpd.servers = [
          "0.pool.ntp.org"
          "1.pool.ntp.org"
          "2.pool.ntp.org"
          "3.pool.ntp.org"
        ];
        services.openntpd.extraConfig = ''
          listen on ${localAddress}
        '';
      };
  };

}]
