{ inputs, cell, ... }:

{ config, lib, containers, ... }:
with lib;
let
  cfg = config.deploy.params.lan.server.recursor;
  lan = config.deploy.params.lan.server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
in
{
  containers."${namespace}-powerdns-recursor" = {
    additionalCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_CHOWN" ];
    inherit (lan) macvlans;

    timeoutStartSec = "120s";
    autoStart = true;
    ephemeral = true;

    config =
      {
        imports = containers.systemd;

        networking.hostName = "powerdns-recursor";
        networking.domain = lan.domain;

        networking.firewall.allowedUDPPorts = [ 53 ];
        networking.firewall.allowedTCPPorts = [ 8082 ];

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        ### NOTE: https://doc.powerdns.com/md/recursor/dnssec
        services.pdns-recursor = {
          inherit (cfg) forwardZones;

          luaConfig = ''
            addTA('${lan.domain}', "28954 13 1 dd20d7bcf9bd496764f3139a2e399f17f23e6ea9")
            addTA('${lan.domain}', "28954 13 2 40aa13aa4448ad12cb39d0c55d862a396607686553a40031414367da30d92bb9")
            addTA('${lan.domain}', "28954 13 4 a10bf0ecbce1b088554bb01524314f4456de411ceab7f75e7fb6ffa4df7a4763a1615df99f95a73138d8c4a5c4a4517c")

            addTA('${lan.domain}', "50438 13 1 13f7dcb349d27ae5d2ba2760b28ad787cbe305ca")
            addTA('${lan.domain}', "50438 13 2 602b78c70a7647367cd4f66d49ab739966a1f0988281af829426c4912acbb96e")
            addTA('${lan.domain}', "50438 13 4 73750fda3b9f1992f476919bcdc5ac68e5f48c470b7f5b49e148183ce756958dc32f951f0edc8d1c0afb1e0f87130e83")
          '';

          enable = true;
          resolveNamecoin = true;

          api.allowFrom = [ lan.network ];
          api.address = localAddress;
          api.port = 8082;

          dns.allowFrom = [ lan.network ];
          dns.address = localAddress;

          dnssecValidation = "process";

          settings.loglevel = 3;
          settings.log-common-errors = true;
          settings.max-cache-ttl = 15;
          # settings.trace = "yes";
        };
      };
  };

}
