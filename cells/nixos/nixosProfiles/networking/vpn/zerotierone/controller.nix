{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    concatStringsSep
    mkEnableOption
    mergeAttrsList
    mapAttrsToList
    optionalString
    hasAttrByPath
    nameValuePair
    fileContents
    splitString
    reverseList
    filterAttrs
    attrValues
    attrNames
    mapAttrs
    mapAttrs'
    fromJSON
    mkOption
    genAttrs
    isString
    flatten
    mkMerge
    readDir
    toLower
    length
    toPath
    isNull
    foldl'
    imap1
    toInt
    types
    take
    last
    mkIf
    head;

  path = toPath (config.sops.secrets.zerotierKey.sopsFile + "/../..");
  names = attrNames (readDir path);
  idOf = name: head (attrNames (readDir (toPath (path + "/" + name))));
  members = mergeAttrsList (map
    (name:
      {
        ${idOf name} = {
          inherit name;
          authorized = true;
          activeBridge = true;
        };
      })
    names);
in
{
  imports =
    # [ cell.nixosModules.services.networking.kea-vpn-bridge ] ++
    [ cell.nixosModules.services.networking.kea-vpn-interfaces ] ++

    [
      cell.nixosProfiles.networking.dhcp-ddns.postgresql
      cell.nixosProfiles.networking.dhcp-ddns.powerdns
      cell.nixosProfiles.networking.dhcp-ddns.kea
    ];

  config = mkMerge [
    { services.zerotierone.controller.enable = true; }

    {
      services.kea.dhcp-ddns.settings =
        let
          inherit (config.services.zerotierone.controller.networks.admin-dhcp)
            cidr
            dns;
          dns-servers = [{
            ip-address = config.services.powerdns.virtualInstances.default.settings.local-address; # NOTE: Must match the powerdns allow-dnsupdate-from cidr.minaddr;
            port = toInt config.services.powerdns.virtualInstances.default.settings.local-port; # NOTE: Must match the powerdns local-address port!
          }];
        in
        {
          forward-ddns.ddns-domains = [{
            inherit dns-servers;
            name = dns.domain + ".";
          }];

          reverse-ddns.ddns-domains = [{
            inherit dns-servers;
            name = cidr.ptr + ".";
          }];
        };
    }

    {
      systemd.services.kea-dhcp4-server.after = [ "postgresql.service" ];
      systemd.services.kea-dhcp-ddns-server.after = [ "kea-dhcp4-server.service" ];

      networking.firewall.interfaces."njk.local".allowedUDPPorts = [
        (toInt config.services.powerdns.virtualInstances.default.settings.local-port)
      ];

      # services.resolved.dnssec = "allow-downgrade";
      # services.resolved.llmnr = "false";

      services.adguardhome.settings.dns.port = 5353;
      services.powerdns.virtualInstances.default.settings.local-port = "53";
      services.powerdns.virtualInstances.default.settings.local-address =
        config.services.zerotierone.controller.networks.admin-dhcp.cidr.minaddr;
      services.powerdns.virtualInstances.default.settings.allow-dnsupdate-from =
        "${config.services.zerotierone.controller.networks.admin-dhcp.cidr.minaddr}/32";

      services.kea.vpn-interfaces.zerotierone."njk.local" =
        let
          inherit (config.services.zerotierone.controller.networks.admin-dhcp)
            cidr
            dns;
        in

        {
          # bridge.enable = true;
          # networkd.addresses = [ "10.0.0.1/24" "10.0.1.1/24" ];
          networkID = "ba8ec53f7ab4e74f";
          IPaddress = "${cidr.minaddr}/${cidr.prefix}";
          subnet4 = [{
            # id = 1;
            subnet = "${cidr.network}/${cidr.prefix}";
            pools = [{ inherit (cidr) pool; }];
            ddns-generated-prefix = "host";
            ddns-qualifying-suffix = dns.domain;
            option-data = [
              { name = "domain-name-servers"; data = cidr.minaddr; }
              { name = "domain-search"; data = dns.domain; }
              # { name = "routers"; data = cidr.minaddr; }
              { name = "domain-name"; data = dns.domain; }
            ];
          }];

        };
    }
    /*
      {
      boot.kernel.sysctl."net.core.default_qdisc" = "fq_codel";
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    */

    {
      services.powerdns.virtualInstances.default = {
        # NOTE: { mutable = true; } to skip deleting zones, otherwise ddns hosts will disappear.
        # The alternative is to drop kea and powerdns databases on postgresql startup.
        zones = mapAttrs
          (n: v:
            if v.mutable == false
            then v // { mutable = true; }
            else v)
          config.services.zerotierone.controller.networks.admin-dhcp.zones;
      };

      services.zerotierone.controller.networks.admin-dhcp =
        # self managed dhcp/ddns/ipxe
        {
          cidr = "192.168.121.0/24";
          dns.domain = "njk.local";
          dns.servers = [ config.services.zerotierone.controller.networks.admin-dhcp.cidr.minaddr ];
          id = "ba8ec53f7ab4e74f";
          name = "kea-dhcp - njk.local";
          mutable = false;
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          inherit members;
        };
    }

    {
      services.zerotierone.controller.networks.admin =
        # ZT ip managed
        let pref = "10.0.1"; in
        {
          id = "ba8ec53f7acfdaa1";
          name = "Admin network - admin.njk.local";
          mutable = false;
          ipAssignmentPools = [{ ipRangeStart = "${pref}.100"; ipRangeEnd = "${pref}.200"; }];
          routes = [{ target = "${pref}.0/24"; }];
          inherit members;
        };
    }
  ];
}
