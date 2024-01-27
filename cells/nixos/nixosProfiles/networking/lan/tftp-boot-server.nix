{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.tftp-server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  dhcpServerAddress = head (splitString "/" (head (lan.kea-dhcp.addresses)).addressConfig.Address);
  ztBridges = (attrNames config.containers.kea-dhcp.config.services.kea.vpn-bridges.zerotierone) != [ ];
  dhcpHasBridges = (localAddress != dhcpServerAddress) && ztBridges;
  namespace = "lan-" + lan.domain;
in

mkMerge [
  (mkIf dhcpHasBridges {
    # TODO: secrets and zerotier bridges
  })

  {
    containers."${namespace}-tftp-boot-server" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      config =
        {
          imports = containers.systemd;

          networking.hostName = "tftp-boot-server";
          networking.domain = lan.domain;
          networking.firewall.allowedUDPPorts = [ 69 ];

          deploy.params.lan.dhcpClient = false;
          systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

          services.atftpd.enable = true;
          services.atftpd.root = config.services.netboot.root;
          services.atftpd.extraOptions = [ "--bind-address 0.0.0.0" ]; # bridged interfaces might be connected
        };
    };

  }
]
