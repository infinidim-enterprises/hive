{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  systemd.network = {
    networks.local-eth-debug.macvlan = [ "lan-debug" ];
    networks.local-eth-debug.matchConfig.Name = "enp0s20f0u5";
    networks.local-eth-debug.linkConfig.ARP = false;

    netdevs.lan-debug.enable = true;
    netdevs.lan-debug.netdevConfig.Kind = "macvlan";
    netdevs.lan-debug.netdevConfig.Name = "lan-debug";
    netdevs.lan-debug.macvlanConfig.Mode = "bridge";

    networks.lan-debug.networkConfig.DNSSEC = false;
    networks.lan-debug.matchConfig.Name = "lan-debug";
    networks.lan-debug.linkConfig.ARP = true;
    networks.lan-debug.linkConfig.RequiredForOnline = "no";
    networks.lan-debug.DHCP = "yes";
    networks.lan-debug.networkConfig.DHCP = "yes";
    networks.lan-debug.dhcpV4Config = {
      ClientIdentifier = "mac";
      UseDNS = false;
      UseNTP = false;
      UseSIP = false;
      UseMTU = true;
      UseHostname = false;
      UseRoutes = false;
      UseTimezone = false;
      Anonymize = false;
      SendHostname = true;
      SendRelease = true;
    };

  };
}
