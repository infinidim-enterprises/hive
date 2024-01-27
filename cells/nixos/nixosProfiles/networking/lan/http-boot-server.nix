{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.http-server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  dhcpServerAddress = head (splitString "/" (head (lan.kea-dhcp.addresses)).addressConfig.Address);
  powerdnsAdminIp = head (splitString "/" (head (lan.powerdns-admin.addresses)).addressConfig.Address);
  mutablePresent = hasAttr "mutableDirs" cfg;

  ztBridges = (attrNames config.containers.kea-dhcp.config.services.kea.vpn-bridges.zerotierone) != [ ];
  dhcpHasBridges = (localAddress != dhcpServerAddress) && ztBridges;
  namespace = "lan-" + lan.domain;
in

mkMerge [
  (mkIf mutablePresent {
    containers."${namespace}-http-boot-server" = {

      bindMounts = listToAttrs
        (map
          (hostPath:
            nameValuePair
              (replaceStrings [ "/" ] [ "-" ] hostPath)
              { inherit hostPath; mountPoint = hostPath; isReadOnly = true; })
          cfg.mutableDirs);

      config = {
        services.httpd.virtualHosts.localhost.servedDirs = map
          (dir: { inherit dir; urlPath = "/mutable/" + (baseNameOf dir); })
          cfg.mutableDirs;
      };
    };
  })

  {
    containers."${namespace}-http-boot-server" = {

      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      config = {
        imports = containers.systemd;

        networking.hostName = "http-boot-server";
        networking.domain = lan.domain;
        networking.firewall.allowedTCPPorts = [ 80 ];

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        services.httpd.enable = true;
        services.httpd.virtualHosts.localhost = {
          documentRoot = config.services.netboot.root;
          adminAddr = "httpd@${config.networking.hostName}.${config.networking.domain}";
          listen = [{ ip = "*"; port = 80; }];
        };
      };
    };

  }
]
