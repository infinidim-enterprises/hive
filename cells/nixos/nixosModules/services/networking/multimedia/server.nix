{ config, lib, pkgs, containers, ... }:
with lib;
let
  cfg = config.services.multimedia.server;
in
{
  options.services.multimedia.server = with types; {
    enable = mkEnableOption "Multimedia downloader and server for local consumption";
    namespace = mkOption { type = str; default = "multimedia"; };
    macvlans = mkOption { type = listOf str; default = [ "lan" ]; };
    secrets.vpn = mkOption { type = listOf str; };
    containerTemplate = mkOption {
      internal = true;
      type = attrs;
      default = {
        additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        inherit (cfg) macvlans;
        timeoutStartSec = "2m";
        autoStart = true;
        ephemeral = true;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {

      containers."${cfg.namespace}-gateway-vpn" = cfg.containerTemplate // {
        enableTun = true;

        # additionalCapabilities = [
        #   "CAP_NET_BIND_SERVICE"
        #   # "CAP_NET_ADMIN"
        # ];

        bindMounts = listToAttrs
          (map
            (hostPath:
              nameValuePair
                (replaceStrings [ "/" ] [ "-" ] hostPath)
                { inherit hostPath; mountPoint = hostPath; isReadOnly = true; })
            cfg.secrets.vpn);

        config = {
          imports = containers.systemd;
          boot.kernel.sysctl."net.core.default_qdisc" = "fq_codel";
          boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

          systemd.network.networks.lan = {
            dhcpV4Config.ClientIdentifier = "mac";
            linkConfig.MACAddress = "00:f1:a1:b1:1a:b0";

            networkConfig.IPForward = true;
            networkConfig.IPMasquerade = "ipv4";
          };

          services.openvpn.servers.cyberghost-nl-client = {
            config = ''
              client
              remote 87-1-nl.cg-dialup.net 443
              dev tun
              proto udp

              resolv-retry infinite
              redirect-gateway def1
              persist-key
              persist-tun
              nobind
              cipher AES-256-CBC
              ncp-disable
              auth SHA256
              ping 5
              ping-exit 60
              ping-timer-rem
              explicit-exit-notify 2
              script-security 2
              remote-cert-tls server
              route-delay 5
              verb 4

              auth-user-pass /run/secrets/auth-user-pass

              ca /run/secrets/ca.crt
              cert /run/secrets/client.crt
              key /run/secrets/client.key
            '';
            # up = "echo nameserver $nameserver | ${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
            # down = "${pkgs.openresolv}/sbin/resolvconf -d $dev";
          };


        };
      };

      containers."${cfg.namespace}-samba" = cfg.containerTemplate // {
        config = {
          imports = containers.systemd;
          systemd.network.networks.lan.dhcpV4Config.ClientIdentifier = "mac";
          systemd.network.networks.lan.linkConfig.MACAddress = "00:f1:a1:b1:1a:a0";
        };
      };

    })
  ];
}
