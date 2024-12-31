# TODO: Implement moon functionality https://www.zerotier.com/manual/#4_4
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.zerotierone;
  isNetworkd = config.systemd.network.enable;
  isNetworkManager = config.networking.networkmanager.enable;
  isDhcpcd = config.networking.dhcpcd.enable;
  isContainer = config.boot.isContainer;
  sanitize = with types; with builtins; cfgChunk: getAttr (typeOf cfgChunk) {
    bool = cfgChunk;
    int = cfgChunk;
    string = cfgChunk;
    list = map sanitize cfgChunk;
    set = mapAttrs
      (const sanitize)
      (filterAttrs
        (name: value: name != "_module" &&
          name != "mutable" &&
          name != "members" &&
          name != "apply" &&
          value != null)
        cfgChunk);
  };

  localConfOptionsPhysical = with types;
    { ... }: {
      options = {
        blacklist = mkEnableOption "If true, blacklist this path for all ZeroTier traffic";
        trustedPathId = mkOption {
          description = "If present and nonzero, define this as a trusted path";
          default = null;
          type = nullOr int;
        };
        mtu = mkOption {
          description = "if present and non-zero, set UDP maximum payload MTU for this path";
          default = null;
          type = nullOr int;
        };
      };
    };

  localConfOptionsVirtual = with types;
    { ... }: {
      options = {
        blacklist = mkOption {
          description = "Blacklist a physical path for only this peer.";
          example = [ "NETWORK/bits" ];
          default = null;
          type = nullOr (listOf str);
        };
        try = mkOption {
          description = "Hints on where to reach this peer if no upstreams/roots are online";
          example = [ "IP/port" ];
          default = null;
          type = nullOr (listOf str);
        };
      };
    };

  localConfOptionsSettings = with types;
    { ... }: {
      options = {
        primaryPort = mkOption {
          description = "If set, override default port of 9993 and any command line port";
          default = null;
          type = nullOr (ints.between 1 65535);
        };
        secondaryPort = mkOption {
          description = "If set, override default random secondary port";
          default = null;
          type = nullOr (ints.between 1 65535);
        };
        tertiaryPort = mkOption {
          description = "If set, override default random tertiary port";
          default = null;
          type = nullOr (ints.between 1 65535);
        };
        portMappingEnabled = mkOption {
          default = null;
          type = nullOr bool;
          description = "If true (the default), try to use uPnP or NAT-PMP to map ports";
        };
        allowSecondaryPort = mkOption {
          default = null;
          type = nullOr bool;
          description = "false will also disable secondary port";
        };
        softwareUpdate = mkOption {
          default = "disable";
          type = enum [ "apply" "download" "disable" ];
          description = ''
            Automatically apply updates, just download, or disable built-in software updates
            This is nixos module, so the default is always "disable"
            The other 2 options - softwareUpdateChannel softwareUpdateDist have no meaning, hence skipped.
          '';
        };
        interfacePrefixBlacklist = mkOption {
          description = "Array of interface name prefixes (e.g. eth for eth#) to blacklist for ZT traffic";
          default = null;
          type = nullOr (listOf str);
        };
        allowManagementFrom = mkOption {
          description = "If non-NULL, allow JSON/HTTP management from this IP network. Default is 127.0.0.1 only.";
          example = [ "NETWORK/bits" ];
          default = null;
          type = nullOr (listOf str);
        };
        bind = mkOption {
          description = "If present and non-null, bind to these IPs instead of to each interface (wildcard IP allowed)";
          example = [ "ip" ];
          default = null;
          type = nullOr (listOf str);
        };
        allowTcpFallbackRelay = mkOption {
          default = null;
          type = nullOr bool;
          description = "Allow or disallow establishment of TCP relay connections (true by default)";
        };
        multipathMode = mkOption {
          default = null;
          type = nullOr (enum [ 0 1 2 ]);
          description = "multipath mode: none (0), random (1), proportional (2)";
        };
      };
    };

  localConfOptions = with types;
    { ... }: {
      options = {
        physical = mkOption {
          description = "Settings that apply to physical L2/L3 network paths.";
          default = null;
          type = nullOr (attrsOf (submodule [ localConfOptionsPhysical ]));
        };
        virtual = mkOption {
          description =
            "Settings applied to ZeroTier virtual network devices (VL1)";
          default = null;
          type = nullOr (attrsOf (submodule [ localConfOptionsVirtual ]));
        };
        settings = mkOption {
          description = "Other global settings";
          default = null;
          type = nullOr (submodule localConfOptionsSettings);
        };
      };
    };

in
{
  #### Interface
  options.services.zerotierone = with types; {

    enable = mkEnableOption "ZeroTierOne" // { default = (length cfg.joinNetworks) > 0; };
    localConf = mkOption {
      description = ''
        A file called local.conf in the ZeroTier home folder contains configuration options that apply to the local node.
        It can be used to set up trusted paths, blacklist physical paths, set up physical path hints for certain nodes, and define trusted upstream devices (federated roots).
        https://www.zerotier.com/manual/#4_2
      '';
      default = null;
      type = nullOr (submodule localConfOptions);
    };

    joinNetworks = mkOption {
      default = [ ];
      example = [{ "a8a2c3c10c1a68de" = "device_name"; }];
      type = listOf attrs;
      description = ''
        List of attributes of ZeroTier Network IDs to join on startup
        and corresponding device names to assign via devicemap file
      '';
    };

    skipNetworkdConfig = mkOption {
      default = null;
      example = [ "nic-name" ];
      type = nullOr (listOf str);
      description = ''
        Ability to custom configure the .network files for a particular interface.
        whatever is in the list will not be picked up by auto-reconfig.
        Used for kea-dhcp to bridge into zt network.
      '';
    };

    homeDir = mkOption {
      default = "/var/lib/zerotier-one";
      example = "/var/lib/zerotier-one";
      type = str;
      description = ''
        Defaults to /var/lib/zerotier-one
      '';
    };

    privateKeyFile = mkOption {
      # TODO: privateKeyFile
      default = null;
      example = "/run/secrets/age_secret";
      type = nullOr str;
      description = ''
        ZeroTier private key file.
      '';
    };

    package = mkOption {
      default = pkgs.zerotierone;
      defaultText = "pkgs.zerotierone";
      type = package;
      # apply = p: p.overrideAttrs (o: {
      #   installPhase = o.installPhase + ''
      #     mkdir -p $out/share/bash-completion/completions
      #     cat zerotier-cli-completion.bash > $out/share/bash-completion/completions/zerotier-cli
      #   '';
      # });
      description = ''
        ZeroTier One package to use.
      '';
    };

    service_path_pkgs = mkOption {
      default = with pkgs; [
        nix
        systemd
        diffutils
        iproute2
        iptables
        bridge-utils
        httpie
        jq
        libressl.nc
      ];
      type = listOf package;
      description = ''
        Helper script bin paths
      '';
    };

    service_port = mkOption {
      description = "Listen UDP port";
      default = 9993;
      type = int;
    };

    service_script_timeout = mkOption {
      type = either str int;
      default = 30;
      apply = builtins.toString;
    };

    # TODO: service_script per network
    # zerotier-cli -j listnetworks |jq '.[] | {id, name, portDeviceName, assignedAddresses}'
    service_script = mkOption {
      default = ''
        # [[ $(iptables-save | grep "\-A INPUT \-i $1 \-j ACCEPT") ]] && true || iptables -I INPUT -j ACCEPT -i $1
        # Or set something up with networkd
      '';
      type = nullOr str;
      description = ''
        This will fire on UDEV add|change for zt interfaces
      '';
    };

  };

  imports = [
    { disabledModules = [ "services/networking/zerotierone.nix" ]; }
    ./controller.nix
  ];

  config = mkMerge [
    { assertions = [{ assertion = isNetworkd; message = "Requires systemd.network.enable"; }]; }

    (mkIf (cfg.enable && isDhcpcd) {
      networking.dhcpcd.denyInterfaces = [ "zt*" ] ++ (map (n: head (attrValues n)) cfg.joinNetworks);
      networking.dhcpcd.persistent = mkDefault true;
    })

    (mkIf cfg.enable {
      # ZeroTier UDP on port 9993 by default
      networking.firewall.allowedUDPPorts = [ cfg.service_port ];
      environment.systemPackages = [ cfg.package ];

      systemd.services.zerotierone = {
        description = "ZeroTierOne";
        path = [ cfg.package ] ++ cfg.service_path_pkgs;
        wantedBy = [ "multi-user.target" "remote-fs.target" ];
        after = [ "network.target" ];
        before = [ "remote-fs.target" ];
        requires = [ "network-online.target" ];
        preStart = ''
          mkdir -p ${cfg.homeDir}/networks.d
          chmod 700 ${cfg.homeDir}
          chown -R root:root ${cfg.homeDir} || true
          [[ -f  ${cfg.homeDir}/devicemap ]] && rm -rf ${cfg.homeDir}/devicemap || true
          touch ${cfg.homeDir}/devicemap
          rm -rf ${cfg.homeDir}/*_state_*.json
        ''
        + (concatMapStrings
          (netId: ''
            touch "${cfg.homeDir}/networks.d/${netId}.conf"
          '')
          (map (n: head (attrNames n)) cfg.joinNetworks))

        + (concatMapStrings
          (net:
            let
              # NOTE: Linux interface names cannot exceed 15 chars
              deviceName = concatStrings (take 15 (stringToCharacters (head (attrValues net))));
            in
            ''
              echo '${head (attrNames net)}=${deviceName}' >> ${cfg.homeDir}/devicemap
            '')
          cfg.joinNetworks)

        + (optionalString (isAttrs cfg.localConf) ''
          cat > ${cfg.homeDir}/local.conf <<EOL
          ${builtins.toJSON (sanitize cfg.localConf)}
          EOL
        '')
        + (
          let
            jqFilter = ''.Interfaces[] | select(.AddressState == "routable" and .OperationalState == "routable" and .IPv4AddressState == "routable") | any'';
          in
          ''
            until networkctl --json=short | jq -e '${jqFilter}'
            do
              echo 'Missing usable devices, sleeping for 5...'
              sleep 5
            done
          ''
        );

        serviceConfig.ExecStart = "${cfg.package}/bin/zerotier-one -p${builtins.toString cfg.service_port} ${cfg.homeDir}";
        serviceConfig.Restart = "always";
        serviceConfig.KillMode = "process";
        serviceConfig.TimeoutStopSec = 5;
      };

      systemd.services."zerotierone-ifcfg@" = {
        path = [ cfg.package ] ++ cfg.service_path_pkgs;
        after = [ "zerotierone.service" ];
        partOf = [ "zerotierone.service" ];
        description = "%i changes sync";
        script = cfg.service_script;
        scriptArgs = "%i";
        serviceConfig.Restart = "on-failure";
      };

      services.udev.extraRules =
        let
          rule = dev: ''
            ACTION=="add|change", KERNEL=="${dev}", TAG+="systemd", ENV{SYSTEMD_WANTS}="zerotierone-ifcfg@%k.service"
          '';
          networkNames = map (n: head (attrValues n)) cfg.joinNetworks;
        in
        concatStringsSep "\n" (map rule (networkNames ++ [ "zt*" ]));
    })

    (mkIf (cfg.enable && isContainer && !config.services.kea.dhcp4.enable) {
      # NOTE: A very personal 'Fuck you @edolstra' - spent hours debugging udev inside systemd-nspawn!
      # https://github.com/NixOS/nixpkgs/blame/0f85665118d850aae5164d385d24783d0b16cf1b/nixos/modules/services/hardware/udev.nix#L291
      # NOTE: Another very personal 'Fuck you @systemd developers' - dumbfucks couldn't make udev work properly in containers!
      systemd.services.zerotierone-ifcfg-force = {
        after = [ "zerotierone.service" ];
        wantedBy = [ "zerotierone.service" ];
        path = [ cfg.package ] ++ cfg.service_path_pkgs;
        script = ''
          until zerotier-cli -j info | jq -e '.online';do sleep 5;done
          for device in ${toString (flatten (map attrValues cfg.joinNetworks))};do systemctl --no-block start "zerotierone-ifcfg@''${device}";done
        '';
      };
    })

    (mkIf (cfg.enable && isNetworkd) {
      systemd.services."zerotierone-ifcfg@" =
        let
          ztCli = "zerotier-cli -j listnetworks";
          jqCmd = "jq -e --arg device $DEVICE";
          jqStr = ''.[] | select(.portDeviceName == $device and .status == "OK") | if .status == "OK" then true else null end'';
          network = ''.[] | select(.portDeviceName == $device) | del(.multicastSubscriptions)'';
          skipNetworkStr = ". != null and (.[] | contains($device))";
        in

        {
          environment.NIX_REMOTE = "daemon";
          serviceConfig.Type = "notify";
          script = mkAfter ''
            DEVICE=$1
            LOC=$(mktemp -d)
            NOW=''${LOC}/''${DEVICE}_state_now.json
            BEFORE=''${LOC}/''${DEVICE}_state_before.json

            export DEVICE NOW BEFORE LOC

            _state_now() {
              ${ztCli} | ${jqCmd} '${network}' > $NOW
            }

            _state_before() {
              ${ztCli} | ${jqCmd} '${network}' > $BEFORE
            }

            _state_change() {
              nix eval -I nixpkgs=${pkgs.path} --raw --impure --expr \
                'import ${./networkd-runtime.nix} { networkJson = builtins.getEnv "NOW";}' > /etc/systemd/network/$DEVICE.network
              networkctl reload
            }

            _execute() {
              _state_now
              [[ ! -f $BEFORE ]] && _state_change || (diff $NOW $BEFORE > /dev/null || _state_change)
              _state_before
            }

            _skipNetworkdConfig() {
              echo '${builtins.toJSON cfg.skipNetworkdConfig}' | ${jqCmd} '${skipNetworkStr}' > /dev/null
            }

            _cond() {
              ${ztCli} | ${jqCmd} '${jqStr}' > /dev/null
            }

            _op() {
              _skipNetworkdConfig || _execute
            }

            systemd-notify --no-block --ready --status="Monitoring ''${DEVICE} for changes"
            until _cond;do sleep 3;done
            while _cond;do _op && sleep ${cfg.service_script_timeout};done
          '';

          serviceConfig.ExecStop = (pkgs.writeShellScript "postStop" ''
            # cleanup dangling .network files
            NETWORK="/etc/systemd/network/''${1}.network"
            echo "going to rm $NETWORK"
            [[ -f $NETWORK ]] && rm -rf $NETWORK
          '') + " %i";
        };

      systemd.network.links."50-zerotier-keep-mac" = {
        matchConfig.OriginalName = "zt* " + (concatStringsSep " " (map (n: head (attrValues n)) cfg.joinNetworks));
        linkConfig.AutoNegotiation = true;
        linkConfig.MACAddressPolicy = "none";
        extraConfig = ''
          Description=Prevent MAC change on zt links
        '';
      };

    })
  ];
}
