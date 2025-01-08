{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    mkEnableOption
    mergeAttrsList
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

    # self managed dhcp/ddns/ipxe
    {
      services.zerotierone.controller.networks.admin-dhcp =
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

    # ZT ip managed
    {
      services.zerotierone.controller.networks.admin =
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
