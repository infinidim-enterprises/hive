{ config, lib, pkgs, ... }:

let
  # netdevsZT = listToAttrs (n: v: nameValuePair) (cfg.zerotierone);

  # netdevsBr = mapAttrs'
  #   (n: v:
  #     let
  #       brName = "br-${net}";
  #     in
  #     nameValuePair brName { enable = true; netdevConfig.Kind = "bridge"; netdevConfig.Name = brName; }
  #   )
  #   cfg.zerotierone;

  # systemdNetworks = op: (map
  #   (net:
  #     let
  #       brName = "br-${net}";
  #       netCfg = cfg.zerotierone.${net};
  #     in
  #     {
  #       netdevs.${brName} = {
  #         enable = true;
  #         netdevConfig.Kind = "bridge";
  #         netdevConfig.Name = brName;
  #       };

  #       networks.${brName} = {
  #         matchConfig.Name = brName;
  #         linkConfig.ARP = true;
  #         linkConfig.RequiredForOnline = "yes";

  #         networkConfig.DNSSEC = false;
  #         networkConfig.IPv6AcceptRA = "no";
  #         networkConfig.LinkLocalAddressing = "no";
  #         networkConfig.IPForward = "ipv4";
  #         networkConfig.IPMasquerade = mkIf (netCfg.IPMasquerade != null) netCfg.IPMasquerade;

  #         addresses = map (s: { addressConfig.Address = getMaxAddress s.subnet; }) netCfg.subnet4;
  #       };
  #     })
  #   (attrNames op));

  # foldAttrs recursiveUpdate {} [{}]
  # configZerotier = map
  #   (net:
  #     let
  #       brName = "br-${net}";
  #       netCfg = cfg.zerotierone.${net};
  #     in
  #     {
  #       services.zerotierone.joinNetworks = [{ ${networkId} = deviceName; }];
  #       services.zerotierone.skipNetworkdConfig = [ deviceName ];
  #       services.zerotierone.localConf.settings.interfacePrefixBlacklist = [ deviceName ];

  #       services.kea.dhcp4.settings = {
  #         interfaces-config.interfaces = [ brName ];
  #         subnet4 = map (s: s // { interface = brName; }) netCfg.subnet4;
  #       };

  #       systemd.network = {
  #         netdevs.${brName} = {
  #           enable = true;
  #           netdevConfig.Kind = "bridge";
  #           netdevConfig.Name = brName;
  #         };

  #         networks.${brName} = {
  #           matchConfig.Name = brName;
  #           linkConfig.ARP = true;
  #           linkConfig.RequiredForOnline = "yes";

  #           networkConfig.DNSSEC = false;
  #           networkConfig.IPv6AcceptRA = "no";
  #           networkConfig.LinkLocalAddressing = "no";
  #           networkConfig.IPForward = "ipv4";
  #           networkConfig.IPMasquerade = mkIf (netCfg.IPMasquerade != null) netCfg.IPMasquerade;

  #           addresses = map (s: { addressConfig.Address = getMaxAddress s.subnet; }) netCfg.subnet4;
  #         };

  #       };
  #       # // (recursiveMerge (map
  #       #   (ztNet:
  #       #     let
  #       #       deviceName = head (attrValues ztNet);
  #       #     in
  #       #     { networks.${deviceName} = { matchConfig.Name = deviceName; networkConfig.Bridge = "${brName}"; }; })
  #       #   netCfg.joinNetworks));
  #     })
  #   (attrNames cfg.zerotierone);

  # try_1 = mapAttrs
  #   (_: net:
  #     let
  #       brName = "br-${net}";
  #       netCfg = cfg.zerotierone."${net}";
  #     in
  #     {
  #       systemd.network = {
  #         netdevs."${brName}" = {
  #           enable = true;
  #           netdevConfig.Kind = "bridge";
  #           netdevConfig.Name = brName;
  #         };
  #       };
  #     })
  #   cfg.zerotierone;

in
{ }
