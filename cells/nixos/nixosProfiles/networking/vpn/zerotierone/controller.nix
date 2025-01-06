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
    types
    mkIf
    head;

  path = toPath (config.sops.secrets.zerotierKey.sopsFile + "/../..");
  names = attrNames (readDir path);
  idOf = name: head (attrNames (readDir (toPath (path + "/" + name))));
  members = mergeAttrsList (map
    (name:
      { ${idOf name} = { inherit name; authorized = true; activeBridge = true; }; })
    names);

  ipCalc = subnet:
    mapAttrs' (n: v: nameValuePair (toLower n) v)
      (fromJSON (fileContents (pkgs.runCommandNoCC "ipcalc"
        { buildInputs = with pkgs; [ ipcalc ]; } ''
        ipcalc ${subnet} --json > $out
      '')));

  cfg = config.services.networks;

  ipOptions = { name, ... }:
    with types;
    {
      options = {
        addresses = mkOption { type = str; };
        addrspace = mkOption { type = str; };
        broadcast = mkOption { type = str; };
        maxaddr = mkOption { type = str; };
        minaddr = mkOption { type = str; };
        netmask = mkOption { type = str; };
        network = mkOption { type = str; };
        prefix = mkOption { type = str; };
      };
    };

  networkOptions = { name, ... }:
    with types;
    {
      options = {
        enable = mkEnableOption "SDN" // { default = true; };
        domain = mkOption { type = str; };
        # cidr = mkOption {
        #   type = oneOf [ str (submodule [ ipOptions ]) ];
        #   apply = x:
        #     if isString x
        #     then ipCalc x
        #     else x;
        # };
        cidr = mkOption { type = submodule [ ipOptions ]; apply = _: ipCalc name; };
      };
    };
in
{
  imports =
    [ cell.nixosModules.services.networking.kea-vpn-bridge ]
    ++ (with cell.nixosProfiles.networking.vpn.zerotierone; [
      service-dns
    ]);

  options.services = with types; {
    sdn = mkOption {
      description = "SDN Networks";
      default = null;
      type = nullOr (attrsOf (submodule [ networkOptions ]));
    };

  };

  config = mkMerge [

    {
      services.sdn."10.0.0.0/24" = {
        domain = "njk.local";
        # cidr = "10.0.0.0/24";
      };

      # services.networks.kea-dhcp = {
      #   domain = "njk.local";
      #   cidr = "10.0.0.0/24";
      #   # cidr = ipCalc "10.0.0.0/24";
      # };

      services.zerotierone.controller.networks.kea-dhcp =
        {
          id = "ba8ec53f7ab4e74f";
          name = "kea-dhcp - njk.local";
          mutable = false;
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
          inherit members;
        };
    }

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
  ];
}
