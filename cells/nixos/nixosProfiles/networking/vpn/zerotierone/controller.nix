{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    mergeAttrsList
    attrNames
    genAttrs
    readDir
    toPath
    head;
  path = toPath (config.sops.secrets.zerotierKey.sopsFile + "/../..");
  names = attrNames (readDir path);
  idOf = name: head (attrNames (readDir (toPath (path + "/" + name))));
  members = mergeAttrsList (map
    (name:
      { ${idOf name} = { inherit name; authorized = true; activeBridge = true; }; })
    names);
in
{
  services.zerotierone.enable = true;
  services.zerotierone.controller.enable = true;
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
