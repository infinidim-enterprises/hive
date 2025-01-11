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

  managedNetworks = filterAttrs
    (n: v:
      hasAttrByPath [ "cidr" "minaddr" ] v &&
      hasAttrByPath [ "dns" "domain" ] v &&
      hasAttrByPath [ "dns" "servers" ] v)
    config.services.zerotierone.controller.networks;

  SOA = domain: {
    type = "SOA";
    records = [{
      content = "ns1.${domain}. hostmaster.${domain}. 0 10800 3600 604800 3600";
    }];
  };

  rdnsNet = network: concatStringsSep "." (reverseList (take 3 (splitString "." network)));
  rdnsIP = ip: last (splitString "." ip);

  mkZones = net:
    let
      generateForAttr = n: v:
        let
          all = { inherit (v) mutable; };
          soa_ns = [ (SOA v.dns.domain) ] ++
            (imap1
              (i: ip: {
                type = "NS";
                records = [{ content = "ns${toString i}.${v.dns.domain}."; }];
              })
              v.dns.servers);
          A = imap1
            (i: ip: {
              type = "A";
              name = "ns${toString i}";
              records = [{ content = ip; }];
            })
            v.dns.servers;
          PTR = imap1
            (i: ip: {
              type = "PTR";
              name = "${rdnsIP ip}";
              records = [{ content = "ns${toString i}.${v.dns.domain}."; }];
            })
            v.dns.servers;
        in
        {
          "${v.dns.domain}" = all // { rrsets = soa_ns ++ A; };
          "${v.cidr.ptr}" = all // { rrsets = soa_ns ++ PTR; };
        };
      newAttrs = mapAttrs generateForAttr net;
    in
    foldl' (acc: val: acc // val) { } (attrValues newAttrs);

  zones = mkZones managedNetworks;

in
{
  imports =
    [ cell.nixosModules.services.networking.kea-vpn-bridge ] ++

    [
      cell.nixosProfiles.networking.dhcp-ddns.postgresql
      cell.nixosProfiles.networking.dhcp-ddns.powerdns
      cell.nixosProfiles.networking.dhcp-ddns.kea
    ];

  config = mkMerge [
    { services.zerotierone.controller.enable = true; }
    { services.powerdns = { inherit zones; }; }
    {
      services.kea.dhcp-ddns.settings =
        let
          inherit (config.services.zerotierone.controller.networks.admin-dhcp)
            cidr
            dns;
          dns-servers = [{
            ip-address = "127.0.0.1"; # NOTE: Must match the powerdns allow-dnsupdate-from cidr.minaddr;
            port = 5353; # NOTE: Must match the powerdns local-address port!
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
      boot.kernel.sysctl."net.core.default_qdisc" = "fq_codel";
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      services.kea.vpn-bridges.zerotierone."njk-local" =
        let
          inherit (config.services.zerotierone.controller.networks.admin-dhcp)
            cidr
            dns;
        in
        {
          subnet4 = [{
            # subnet configuration failed: missing parameter 'id' (/etc/kea/dhcp4-server.conf:312:7)
            id = 1;
            subnet = "${cidr.network}/${cidr.prefix}";
            pools = [{ inherit (cidr) pool; }];
            ddns-generated-prefix = "host";
            ddns-qualifying-suffix = dns.domain;
            option-data = [
              { name = "domain-name-servers"; data = cidr.minaddr; }
              { name = "domain-search"; data = dns.domain; }
              { name = "routers"; data = cidr.minaddr; }
              { name = "domain-name"; data = dns.domain; }
            ];
          }];
          bridgeIP = cidr.minaddr;
          IPMasquerade = "ipv4";
          joinNetworks = [{ "ba8ec53f7ab4e74f" = "njk-admin"; }];
        };
    }

    {
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
