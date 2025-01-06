{ config, lib, pkgs, ... }:
with lib;

let
  top = config.services.kea;
  cfg = top.vpn-bridges;
  firewallEnabled = config.networking.firewall.enable;
  isNetworkd = config.systemd.network.enable;
  isZerotierone = config.services.zerotierone.enable;

  bridgeOptions = with types; { ... }: {
    options = {
      subnet4 = mkOption { type = listOf attrs; };
      joinNetworks = mkOption { type = listOf attrs; };
      bridgeIP = mkOption { type = nullOr str; default = null; };
      IPMasquerade = mkOption {
        default = null;
        type = nullOr (enum [ "yes" "no" "ipv4" "ipv6" "both" ]);
      };
    };
  };

  getMaxAddress = subnet:
    let
      ip =
        builtins.fromJSON (fileContents (pkgs.runCommandNoCC "ipcalc"
          { buildInputs = with pkgs; [ gawk ipcalc ]; } ''
          ipcalc --maxaddr ${subnet} --json > $out
        ''));
    in
    "${ip.MAXADDR}/${ip.PREFIX}";

  ztBridgeNetworks = flatten (map
    (Bridge: map
      (interfaceName:
        let Name = head (attrValues interfaceName); in
        {
          ${Name} = {
            matchConfig = { inherit Name; };
            networkConfig = { inherit Bridge; };
          };
        })
      cfg.zerotierone.${Bridge}.joinNetworks)
    (attrNames cfg.zerotierone));

  joinNetworks = flatten (map (a: a.joinNetworks) (attrValues cfg.zerotierone));
  skipNetworkdConfig = map (x: head (attrValues x)) joinNetworks;
  physical = listToAttrs (map
    (x:
      nameValuePair
        (head (attrNames x))
        (head (attrValues x)))
    (flatten (attrValues (mapAttrs'
      (n: v: nameValuePair
        n
        (map (sn: { ${sn.subnet} = { blacklist = true; }; }) v.subnet4))
      cfg.zerotierone))));

  jqOnlineSelector = ''.Interfaces[] | select(.Name | test("${concatStringsSep "|" (map (a: "^${a}$") (attrNames cfg.zerotierone))}")) | .CarrierState == "carrier" and .IPv4AddressState == "routable"'';
  # .OnlineState == "online" and
in
{
  options.services.kea.vpn-bridges.zerotierone = with types;
    mkOption {
      default = null;
      type = nullOr (attrsOf (submodule [ bridgeOptions ]));
    };

  config = mkIf (cfg.zerotierone != null) (mkMerge [
    {
      assertions = [
        { assertion = isNetworkd; message = "Requires systemd.network.enable"; }
        { assertion = isZerotierone; message = "Requires services.zerotierone.enable"; }
        {
          assertion = (length (filter
            (x:
              (stringLength ("br." + x)) > 15)
            (attrNames cfg.zerotierone))) < 1;
          message = "Interface names cannot exceed 12 chars";
        }
      ];
    }

    (mkIf firewallEnabled {
      # create firewall rules bootp/dhcp/tftp
      networking.firewall.interfaces = mapAttrs'
        (n: _:
          nameValuePair
            "br.${n}"
            { allowedUDPPorts = [ 67 68 69 ]; })
        cfg.zerotierone;
    })

    {
      # create kea.dhcp4.settings
      services.kea.dhcp4.settings = {
        interfaces-config.interfaces = attrNames cfg.zerotierone;
        subnet4 = flatten (map
          (interface: (map
            (i: i // { inherit interface; })
            cfg.zerotierone.${interface}.subnet4))
          (attrNames cfg.zerotierone));
      };

      # Just incase - dont't start kea-bridge until zerotierone interfaces are up
      systemd.services.kea-dhcp4-server.path = with pkgs; [ systemd jq ];
      systemd.services.kea-dhcp4-server.preStart = ''
        until networkctl --json=short | jq -e '${jqOnlineSelector}'
        do
          echo "waiting for networkd to settle interfaces... 3 seconds"
          sleep 3
        done
        sleep 3
      '';

      systemd.services.kea-dhcp4-server.after =
        # NOTE: this seems to work, likely systemd auto-escapes values from definitions?
        [ "systemd-networkd-wait-online.service" ]
        ++ map
          (x:
            "sys-subsystem-net-devices-${x}.device")
          (attrNames cfg.zerotierone);
    }

    {
      # create zerotierone config
      services.zerotierone = {
        # enable = true;
        inherit joinNetworks skipNetworkdConfig;
        localConf = {
          inherit physical;
          settings.interfacePrefixBlacklist = skipNetworkdConfig ++ [ "zt" ];
        };
      };
    }

    {
      # create .network files for zt* type interfaces and put them into configured bridge;
      systemd.network.networks = listToAttrs (map
        (net:
          nameValuePair
            (head (attrNames net))
            (head (attrValues net)))
        ztBridgeNetworks);
    }

    {
      # create bridges
      systemd.network.netdevs = mapAttrs'
        (netName: _: nameValuePair "br.${netName}" {
          enable = true;
          netdevConfig.Kind = "bridge";
          netdevConfig.Name = netName;
        })
        cfg.zerotierone;
    }

    {
      # assign IPs to bridges
      systemd.network.networks = mapAttrs'
        (netName: netValue: nameValuePair "br.${netName}" {
          matchConfig.Name = netName;

          linkConfig.ARP = true;
          linkConfig.RequiredForOnline = "yes";

          networkConfig.DNSSEC = false;
          networkConfig.IPv6AcceptRA = "no";
          networkConfig.LinkLocalAddressing = "no";
          networkConfig.IPForward = "ipv4";

          addresses = map
            (s: {
              addressConfig.Address =
                if isNull netValue.bridgeIP
                then getMaxAddress s.subnet
                else netValue.bridgeIP;
            })
            netValue.subnet4;
        })
        cfg.zerotierone;
    }

    (mkIf ((length (filter (f: f.IPMasquerade != null) (attrValues cfg.zerotierone))) > 0) {
      # patch attrs FIXME: this implies gateway on the dhcp-server, which is wrong!
      systemd.network.networks = mapAttrs'
        (netName: netValue: nameValuePair "br.${netName}" {
          networkConfig = { inherit (netValue) IPMasquerade; };
        })
        (filterAttrs (_: v: v.IPMasquerade != null) cfg.zerotierone);
    }
    )
  ]);
}
