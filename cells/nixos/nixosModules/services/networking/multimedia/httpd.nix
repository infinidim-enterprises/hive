{ config, lib, containers, ... }:
with lib;
let
  top = config.services.multimedia.server;
  cfg = top.httpd;
  containerName = baseNameOf (removeSuffix ".nix" (__curPos.file));
  inherit (top) namespace;
in
{
  options.services.multimedia.server.httpd = with types; {
    enable = mkEnableOption "ProxyPass container";
    locations = mkOption {
      type = uniq attrs;
      example = { "/sabnzbd" = "http://somehost:8080/sabnzbd"; };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      containers."${namespace}-${containerName}" = top.containerTemplate // {
        config = {
          imports = containers.systemd;

          systemd.network.networks.lan.dhcpV4Config.ClientIdentifier = "mac";
          systemd.network.networks.lan.linkConfig.MACAddress = "00:f1:a1:b1:1a:f0";

          networking.firewall.allowedTCPPorts = [ 80 ];
          services.httpd.virtualHosts.localhost = {
            listen = [{ ip = "*"; port = 80; }];
            locations = mapAttrs (_: proxyPass: { inherit proxyPass; }) cfg.locations;
          };
        };
      };

    })
  ];
}
