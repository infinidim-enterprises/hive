{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    concatStringsSep
    mkEnableOption
    mergeAttrsList
    optionalString
    hasAttrByPath
    nameValuePair
    fileContents
    splitString
    reverseList
    filterAttrs
    attrNames
    mapAttrs'
    fromJSON
    mkOption
    genAttrs
    isString
    mkMerge
    readDir
    toLower
    length
    toPath
    isNull
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

  soa = domain: "ns1.${domain}. hostmaster.${domain}. 0 10800 3600 604800 3600";
  SOA = domain: {
    type = "SOA";
    records = [{ content = soa domain; }];
  };

  # 1.168.192.in-addr.arpa
  rdnsNet = network: concatStringsSep "." (reverseList (take 3 (splitString "." network)));
  rdnsIP = ip: last (splitString "." ip);

  zones = (mapAttrs'
    (n: v:
      let
      in
      (nameValuePair v.dns.domain {
        rrsets = [ (SOA v.dns.domain) ] ++
          (imap1
            (i: ip: {
              type = "A";
              name = "ns${toString i}";
              records = [{ content = ip; }];
            })
            v.dns.servers) ++
          (imap1
            (i: ip: {
              type = "NS";
              name = "${v.dns.domain}.";
              records = [{ content = "ns${toString i}.${v.dns.domain}."; }];
            })
            v.dns.servers);
      }))
    managedNetworks) //
  (mapAttrs'
    (n: v:
      (nameValuePair "${rdnsNet v.cidr.network}.in-addr.arpa" {
        rrsets = [ (SOA v.dns.domain) ] ++
          (imap1
            (i: ip: {
              type = "PTR";
              name = "${rdnsIP ip}";
              records = [{ content = "ns${toString i}.${v.dns.domain}."; }];
            })
            v.dns.servers);
      }))
    managedNetworks);
in
{
  imports =
    [ cell.nixosModules.services.networking.kea-vpn-bridge ] ++

    [
      cell.nixosProfiles.networking.dhcp-ddns.postgresql
      cell.nixosProfiles.networking.dhcp-ddns.powerdns
    ];

  config = mkMerge [
    { services.zerotierone.controller.enable = true; }
    { services.powerdns = { inherit zones; }; }

    {
      services.zerotierone.controller.networks.admin-dhcp =
        # self managed dhcp/ddns/ipxe
        {
          cidr = "10.0.0.0/24";
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
