{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    mkEnableOption
    mergeAttrsList
    optionalString
    nameValuePair
    fileContents
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
    toInt
    types
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

  json = pkgs.formats.json { }; # json.generate

  endpoint = { method, zone ? null, path ? null }:
    "http --json ${method}" +
    " " +
    "http://localhost:8081/api/v1/servers/localhost/zones" +
    (optionalString (!isNull zone) "/${zone}.") +
    (optionalString (!isNull path) "/${path}") +
    " " +
    "X-API-Key:\\ testkey";

  req = { name, type, ttl, changetype, content }: {
    rrsets = [{
      inherit type ttl changetype;
      name = name + ".";
      records = [{ inherit content; disabled = false; }];
    }];
  };

  records = [{ }];
  /*

    http --json PATCH http://localhost:8081/api/v1/servers/localhost/zones/njk.local. X-API-Key:\ testkey rrsets:='[{"name": "njk.local.", "type": "SOA", "ttl": 3600, "changetype": "replace", "records": [{"content": "ns1.njk.local. hostmaster.njk.local. 5 10800 3600 604800 3600", "disabled": false}]}]'

     http --json GET http://localhost:8081/api/v1/servers/localhost/zones/njk.local X-API-Key:\ testkey | jq
    pdnsutil:
    create-zone 'njk.local' ns1.njk.local
    increase-serial 'njk.local'
    add-record 'njk.local' ns1 A '10.0.1.114'
    secure-zone 'njk.local'
    rectify-zone 'njk.local'
  */
in
{
  imports =
    [ cell.nixosModules.services.networking.kea-vpn-bridge ] ++

    [
      cell.nixosProfiles.networking.dhcp-ddns.postgresql
      cell.nixosProfiles.networking.dhcp-ddns.powerdns
    ];

  config = mkMerge [

    {
      services.powerdns.zones."njk.local".rrsets = [
        {
          type = "SOA";
          records = [{ content = "ns1.njk.local. hostmaster.njk.local. 5 10800 3600 604800 3600"; }];
        }
        {
          type = "A";
          name = "ns1";
          records = [{ content = "10.0.0.1"; }];
        }
      ];
    }
    { services.zerotierone.controller.enable = true; }

    {
      services.zerotierone.controller.networks.admin-dhcp =
        # self managed dhcp/ddns/ipxe
        {
          cidr = "10.0.0.0/24";
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
