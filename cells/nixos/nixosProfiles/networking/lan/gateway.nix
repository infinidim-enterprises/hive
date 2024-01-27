{ inputs, cell, ... }:

{ self, config, lib, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  inherit (lan) namespace;
  cfg = lan.gateway;
  # localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  localContainers = filterAttrs (k: _: hasPrefix "container@${namespace}" k) config.systemd.services;
  before = filter (x: !hasInfix "gateway" x) (map (x: x + ".service") (attrNames localContainers));
  containerName = baseNameOf (removeSuffix ".nix" (__curPos.file));
  containerHash = builtins.hashFile "md5" __curPos.file;
  # machineid.chars.map.each_with_index {|k, i| (((i + 1) % 2 == 0) && (i + 1) < machineid.chars.size ) ? "#{k}:" : k}.join

  iaid = uuidStr:
    let arr = stringToCharacters uuidStr; in
    concatStrings (imap1
      (i: x:
        if mod i 2 == 0 && i < (length arr)
        then x + ":"
        else x)
      arr);
in
mkMerge [
  {
    services.zerotierone.joinNetworks = [
      { "d3b09dd7f51f90df" = "kea-admin"; }
      { "d3b09dd7f53d1214" = "kea-inst"; }
      { "d3b09dd7f58387ff" = "k3s"; }
    ];
  }

  {
    boot.kernel.sysctl."net.core.default_qdisc" = "fq_codel";
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    # TODO: set broadcast flag for ipvlan! it's not being set by default, hence no DHCP on ipvlan!
    systemd.network.networks.wifi-generic = {
      dhcpV4Config.ClientIdentifier = "duid";
      dhcpV4Config.DUIDType = "vendor";
      dhcpV4Config.DUIDRawData = "00:00:ab:11:f9:2a:c2:77:29:f9:5c:02";
    };

    networking.wireless.enable = true;

    systemd.network.networks.lan = {
      networkConfig.IPForward = true;
      networkConfig.IPMasquerade = "ipv4";
      addresses = [{ addressConfig.Address = config.deploy.params.lan.ipv4; }];
    };
  }

  {
    age.secrets."zerotier-${namespace}-${containerName}" = {
      file = "${self}/secrets/containers/lan/gateway/zt-key.age";
      mode = "0600";
      path = "/run/secrets/gateway-zt.identity.secret";
    };

    systemd.services."container@${namespace}-${containerName}" = { inherit before; };

    containers."${namespace}-${containerName}" = {
      bindMounts.zerotier-id.hostPath = "/run/secrets/gateway-zt.identity.secret";
      bindMounts.zerotier-id.mountPoint = "/var/lib/zerotier-one/identity.secret";
      bindMounts.zerotier-id.isReadOnly = true;

      inherit (lan) macvlans;
      extraFlags = [ "--uuid=${containerHash}" ];
      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;
      enableTun = true;
      config =
        {
          imports = containers.systemd;

          boot.kernel.sysctl."net.core.default_qdisc" = "fq_codel";
          boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

          deploy.params.lan.dhcpClient = false;
          networking.hostName = "gateway";
          networking.domain = lan.domain;

          services.zerotierone.joinNetworks = [
            { "d3b09dd7f51f90df" = "kea-admin"; }
            { "d3b09dd7f53d1214" = "kea-inst"; }
            { "d3b09dd7f58387ff" = "k3s"; }
          ];

          systemd.network.networks.lan = {
            inherit (cfg) addresses;
            networkConfig = { IPMasquerade = "ipv4"; IPForward = true; inherit (lan.networkConfig) Gateway; };
          };
        };
    };
  }
]
