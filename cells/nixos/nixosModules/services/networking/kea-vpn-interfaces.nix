{ config, lib, pkgs, ... }:
with lib;

let
  top = config.services.kea;
  cfg = top.vpn-interfaces;
  format = pkgs.formats.json { };

  enabled_firewall = config.networking.firewall.enable;
  enabled_openssh = config.services.openssh.enable;
  enabled_networkd = config.systemd.network.enable;
  enabled_zerotierone = config.services.zerotierone.enable;

  networkdOptions = with types; { name, ... }: {
    options = {
      matchConfig.Name = mkOption {
        type = str;
        readOnly = true;
        apply = _:
          concatMapStringsSep
            " "
            (e: e.interface)
            cfg.zerotierone."${name}".subnet4;
      };
      linkConfig.ARP = mkEnableOption "ARP" // { default = true; };
      linkConfig.RequiredForOnline = mkOption {
        type = enum [ "yes" "no" ];
        default = "yes";
      };
      networkConfig.DNSSEC = mkEnableOption "DNSSEC";
      networkConfig.IPv6AcceptRA = mkOption {
        type = enum [ "yes" "no" ];
        default = "no";
      };
      networkConfig.LinkLocalAddressing = mkOption {
        type = enum [ "yes" "no" ];
        default = "no";
      };
      networkConfig.IPv4Forwarding = mkEnableOption "IPv4Forwarding";
      networkConfig.IPMasquerade = mkOption {
        default = "no";
        type = enum [ "yes" "no" "ipv4" "ipv6" "both" ];
      };
      addresses = mkOption {
        type = nullOr (listOf str);
        default = null;
        apply = x:
          if isNull x
          then cfg.zerotierone."${name}".IPaddress.addresses
          else cfg.zerotierone."${name}".IPaddress.addresses ++
            (map (e: { Address = e; }) x);
      };
    };
  };

  bridgeOptions = with types; { name, ... }: {
    options = {
      enable = mkEnableOption "Create bridge interface";
      interfaceName = mkOption {
        type = nullOr str;
        default = null;
        apply = x:
          if (!isNull x)
          then x
          else "br.${name}";
      };
    };
  };

  zerotieroneOptions = with types; { name, ... }: {
    options = {
      subnet4 = mkOption {
        default = null;
        type = nullOr format.type;
        apply = x:
          if (!isNull x)
          then
            map
              (subnet: subnet // {
                interface =
                  if (!isNull cfg.zerotierone.${name}.bridge)
                  then cfg.zerotierone.${name}.bridge.interfaceName
                  else name;
              })
              x
          else null;
      };

      networkID = mkOption {
        description = ''Zerotierone network id to join'';
        type = nullOr str;
        apply = x:
          if isString x
          then { ${x} = name; }
          else null;
      };

      IPaddress = mkOption {
        type = nullOr str;
        apply = x:
          if isString x
          then { addresses = [{ Address = x; }]; }
          else null;
      };

      networkd = mkOption {
        default = { };
        type = submodule [ (networkdOptions { inherit name; }) ];
      };

      bridge = mkOption {
        default = null;
        type = nullOr (submodule [ (bridgeOptions { inherit name; }) ]);
      };
    };
  };

  interfaceOptions = with types; { name, ... }: {
    options = {
      zerotierone = mkOption {
        default = null;
        type = nullOr (attrsOf (submodule [ zerotieroneOptions ]));
      };
    };
  };

  # joinNetworks = flatten (map (a: a.joinNetworks) (attrValues cfg.zerotierone));
  # skipNetworkdConfig = map (x: head (attrValues x)) joinNetworks;

in
{
  options.services.kea.vpn-interfaces = with types;
    mkOption {
      default = null;
      type = nullOr (submodule [ interfaceOptions ]);
    };

  config = mkIf (!isNull cfg) (mkMerge [
    {
      assertions = [
        {
          assertion = enabled_networkd;
          message = "Requires systemd.network.enable";
        }
        {
          assertion =
            if (!isNull cfg.zerotierone)
            then enabled_zerotierone
            else true;
          message = "Requires services.zerotierone.enable";
        }
        {
          # FIXME: check all interfaces, not just zt | also, all names are actually known in advance!
          # subnet4 contains interface names to check for stringLength
          assertion = (length (filter
            (x: (stringLength ("br." + x)) > 15)
            (attrNames cfg.zerotierone))) < 1;
          message = "Interface names cannot exceed 12 chars";
        }
        {
          # TODO: support more than a single subnet4 entry per zt interface
          assertion = (filterAttrs (n: v: (length v.subnet4) > 1) cfg.zerotierone) == { };
          message = "This module currently supports only a single subnet4 per zt interface";
        }
      ];
    }

    (mkIf (enabled_firewall && !isNull cfg.zerotierone) {
      # create firewall rules bootp/dhcp/tftp
      networking.firewall.interfaces =
        let
          interfaces = flatten
            (mapAttrsToList
              (_: v:
                map (e: e.interface) v.subnet4)
              cfg.zerotierone);
        in
        genAttrs interfaces (_: {
          allowedUDPPorts = [ 67 68 69 ];
          allowedTCPPorts = optionals
            enabled_openssh
            config.services.openssh.ports;
        });
    })

    {
      systemd.services.kea-dhcp4-server.after = optional
        config.systemd.network.wait-online.enable
        "systemd-networkd-wait-online.service";
    }

    (mkIf (!isNull cfg.zerotierone) {

      systemd.services.kea-dhcp4-server.path = with pkgs; [ systemd jq ];
      # systemd.services.kea-dhcp4-server.preStart = ''
      #   until networkctl --json=short | jq -e '${jqOnlineSelector}'
      #   do
      #     echo "waiting for networkd to settle interfaces... 3 seconds"
      #     sleep 3
      #   done
      #   sleep 3
      # '';

      systemd.services.kea-dhcp4-server.after = flatten
        (mapAttrsToList
          (n: v:
            map (x: "sys-subsystem-net-devices-${x.interface}.device")
              v.subnet4)
          cfg.zerotierone);

      services.kea.dhcp4.settings =
        {
          interfaces-config.interfaces = flatten
            (mapAttrsToList (n: v: map (e: e.interface) v.subnet4)
              cfg.zerotierone);
          subnet4 =
            let
              moduleSubnet4 = flatten
                (mapAttrsToList (n: v: v.subnet4)
                  cfg.zerotierone);
              configSubnet4 = length config.services.kea.dhcp4.settings.subnet4;
            in
            imap0
              (i: e: e // { id = i + configSubnet4; })
              moduleSubnet4;
        };

      services.zerotierone = {
        joinNetworks =
          mapAttrsToList
            (n: v: v.networkID)
            cfg.zerotierone;
        skipNetworkdConfig = attrNames cfg.zerotierone;
      };

      systemd.network.networks = mapAttrs'
        (netName: netConfig:
          nameValuePair netName netConfig.networkd)
        cfg.zerotierone;
    })

  ]);
}
