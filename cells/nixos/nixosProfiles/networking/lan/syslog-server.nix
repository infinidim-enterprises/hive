{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.syslog-server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  # dhcpServerAddress = head (splitString "/" (head (lan.kea-dhcp.addresses)).addressConfig.Address);
  # ztBridges = (attrNames config.containers.kea-dhcp.config.services.kea.vpn-bridges.zerotierone) != [ ];
  # dhcpHasBridges = (localAddress != dhcpServerAddress) && ztBridges;
  namespace = "lan-" + lan.domain;
in

mkMerge [{
  containers."${namespace}-syslog-server" = {

    additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    inherit (lan) macvlans;

    timeoutStartSec = "120s";
    autoStart = true;
    ephemeral = true;

    config = { lib, pkgs, ... }:
      {
        imports = containers.systemd;

        networking.hostName = "syslog-server";
        networking.domain = lan.domain;
        networking.firewall.allowedTCPPorts = [ 514 601 6514 ];
        networking.firewall.allowedUDPPorts = [ 514 ];

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        services.syslog-ng.enable = true;
        services.syslog-ng.configHeader = ''
          @version: 3.34
          @include "scl.conf"
        '';

        # systemd.services.syslog-ng.serviceConfig.ExecStart = lib.mkForce " -d";
        environment.systemPackages = with pkgs; [ vim ];

        services.syslog-ng.extraConfig = ''
          source s_net { default-network-drivers(); };
          destination d_local { file("/tmp/syslog-ng"); };

          log {
            source(s_net);
            destination(d_local);
          };
        '';
      };
  };

}]
