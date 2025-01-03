{ config, lib, pkgs, ... }:

with lib;

let
  sanitize = cfgChunk:
    with builtins;
    getAttr (typeOf cfgChunk) {
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

  top = config.services.zerotierone;
  cfg = top.controller;

  routesOptions = with types; { ... }: {
    options = {
      target = mkOption {
        description = "Destination CIDR";
        default = null;
        type = nullOr str;
      };

      via = mkOption {
        description = "Next hop IP";
        default = null;
        type = nullOr str;
      };

    };
  };

  ipAssignmentPoolOptions = with types; { ... }: {
    options = {
      ipRangeStart = mkOption {
        description = "ipRangeStart";
        default = null;
        type = nullOr str;
      };

      ipRangeEnd = mkOption {
        description = "ipRangeEnd";
        default = null;
        type = nullOr str;
      };

    };
  };

  # TODO: https://github.com/zerotier/ZeroTierOne/blob/master/rule-compiler
  rulesOptions = with types; { ... }: {
    options = {
      type = mkOption {
        description = "Entry type (all caps, case sensitive)";
        default = "ACTION_DROP";
        type = enum [
          "ACTION_DROP" # Drop any packets matching this rule  (none)
          "ACTION_ACCEPT" # Accept any packets matching this rule  (none)
          "ACTION_TEE" # Send a copy of this packet to a node (rule parsing continues)  zt
          "ACTION_REDIRECT" # Redirect this packet to another node  zt
          "ACTION_DEBUG_LOG" # Output debug info on match (if built with rules engine debug)  (none)
          "MATCH_SOURCE_ZEROTIER_ADDRESS" # Match VL1 ZeroTier address of packet sender.  zt
          "MATCH_DEST_ZEROTIER_ADDRESS" # Match VL1 ZeroTier address of recipient  zt
          "MATCH_ETHERTYPE" # Match Ethernet frame type  etherType
          "MATCH_MAC_SOURCE" # Match source Ethernet MAC address  mac
          "MATCH_MAC_DEST" # Match destination Ethernet MAC address  mac
          "MATCH_IPV4_SOURCE" # Match source IPv4 address  ip
          "MATCH_IPV4_DEST" # Match destination IPv4 address  ip
          "MATCH_IPV6_SOURCE" # Match source IPv6 address  ip
          "MATCH_IPV6_DEST" # Match destination IPv6 address  ip
          "MATCH_IP_TOS" # Match IP TOS field  ipTos
          "MATCH_IP_PROTOCOL" # Match IP protocol field  ipProtocol
          "MATCH_IP_SOURCE_PORT_RANGE" # Match a source IP port range  start,end
          "MATCH_IP_DEST_PORT_RANGE" # Match a destination IP port range  start,end
          "MATCH_CHARACTERISTICS" # Match on characteristics flags  mask,value
          "MATCH_FRAME_SIZE_RANGE" # Match a range of Ethernet frame sizes  start,end
          "MATCH_TAGS_SAMENESS" # Match if both sides' tags differ by no more than value  id,value
          "MATCH_TAGS_BITWISE_AND" # Match if both sides' tags AND to value  id,value
          "MATCH_TAGS_BITWISE_OR" # Match if both sides' tags OR to value  id,value
          "MATCH_TAGS_BITWISE_XOR" # Match if both sides' tags XOR to value  id,value
        ];
      };

      not = mkOption {
        description = "If true, MATCHes match if they don't match";
        default = false;
        type = bool;
      };

      "or" = mkOption {
        description = ""; # maybe undocumented
        default = false;
        type = bool;
      };

      zt = mkOption {
        description = "10-digit hex ZeroTier address";
        default = null;
        type = nullOr str;
      };

      etherType = mkOption {
        description = "Ethernet frame type";
        default = null;
        type = nullOr int;
      };

      mac = mkOption {
        description = "Hex MAC address (with or without :'s)";
        default = null;
        type = nullOr str;
      };

      ip = mkOption {
        description = "IPv4 or IPv6 address";
        default = null;
        type = nullOr str;
      };

      ipTos = mkOption {
        description = "IP type of service";
        default = null;
        type = nullOr int;
      };

      ipProtocol = mkOption {
        # https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers
        description = "IP protocol number (e.g. 6 for TCP)";
        default = null;
        type = nullOr int;
      };

      start = mkOption {
        description = "Start of an integer range (e.g. port range)";
        default = null;
        type = nullOr int;
      };

      end = mkOption {
        description = "End of an integer range (inclusive)";
        default = null;
        type = nullOr int;
      };

      id = mkOption {
        description = "Tag ID";
        default = null;
        type = nullOr int;
      };

      value = mkOption {
        description = "Tag value or comparison value";
        default = null;
        type = nullOr int;
      };

      mask = mkOption {
        description = "Bit mask (for characteristics flags)";
        default = null;
        type = nullOr int;
      };
    };
  };

  memberOptions = with types; { ... }: {
    options = {
      authorized = mkOption {
        description = "Is member authorized? (for private networks)";
        default = true;
        type = bool;
      };

      name = mkOption {
        description = "Custom name for a member";
        default = null;
        type = nullOr str;
      };

      activeBridge = mkOption {
        description = "Member is able to bridge to other Ethernet nets";
        default = false;
        type = bool;
      };

      ipAssignments = mkOption {
        description = "Managed IP address assignments";
        default = null;
        type = nullOr (listOf str);
      };

    };
  };

  networkOptions = with types; { ... }: {
    options = {
      mutable = mkOption {
        description = ''
          Keep config from 3rd party API actions?
          On service restart will not delete and recreate network and its members.
          When set to false, will rm -rf $ZT_HOME/controller.d/network/$ZT_NET_ID and .json
        '';
        default = true;
        type = bool;
      };

      id = mkOption {
        description = "16-digit network ID";
        default = "1607197732143954";
        type = str;
      };

      objtype = mkOption {
        description = "Always 'network'";
        default = "network";
        type = str;
      };

      name = mkOption {
        description = "A short name for this network";
        default = "Admin access";
        type = str;
      };

      creationTime = mkOption {
        description = "Time network record was created (ms since epoch)";
        default = null;
        type = nullOr int;
      };

      private = mkOption {
        description = "Is access control enabled?";
        default = true;
        type = bool;
      };

      enableBroadcast = mkOption {
        description = "Ethernet ff:ff:ff:ff:ff:ff allowed?";
        default = true;
        type = bool;
      };

      v4AssignMode = mkOption {
        description = "IPv4 management and assign options, zt or none";
        default = "zt";
        type = str;
      };

      v6AssignMode = mkOption {
        description = "IPv4 management and assign options, zt or none";
        default = "none";
        type = str;
      };

      mtu = mkOption {
        description = "Network MTU (default: 2800)";
        default = 2800;
        type = int;
      };

      multicastLimit = mkOption {
        description = "Maximum recipients for a multicast packet";
        default = 128;
        type = int;
      };

      revision = mkOption {
        description = "Network config revision";
        default = null;
        type = nullOr int;
      };

      routes = mkOption {
        description = "Managed IPv4 and IPv6 routes";
        default = [ ];
        type = listOf (submodule [ routesOptions ]);
      };

      ipAssignmentPools = mkOption {
        description = "IP auto-assign ranges";
        default = [ ];
        type = listOf (submodule [ ipAssignmentPoolOptions ]);
      };

      rulesSource = mkOption { type = nullOr str; default = null; };

      rules = mkOption {
        description = ''
          Traffic rules.
          Rules are evaluated in the order in which they appear in the array.
          There is currently a limit of 256 entries per network.
          Capabilities should be used if a larger and more complex rule set is needed since they allow rules to be grouped by purpose and only shipped to members that need them.
        '';

        default = [
          # Allow only IPv4, IPv4 ARP, and IPv6 Ethernet frames.
          {
            etherType = 2048;
            not = true;
            "or" = false;
            type = "MATCH_ETHERTYPE";
          }

          {
            etherType = 2054;
            not = true;
            "or" = false;
            type = "MATCH_ETHERTYPE";
          }

          {
            etherType = 34525;
            not = true;
            "or" = false;
            type = "MATCH_ETHERTYPE";
          }

          {
            not = false;
            "or" = false;
            type = "ACTION_DROP";
          }

          # Accept anything else. This is required since default is 'drop'.
          {
            not = false;
            "or" = false;
            type = "ACTION_ACCEPT";
          }
        ];

        type = nullOr (listOf (submodule [ rulesOptions ]));
      };

      capabilities = mkOption {
        description = ''
          List of capability objects
          Rules in capabilities are always matched as if the current device is the sender (inbound == false).
          A capability specifies sender side rules that can be enforced on both sides.
        '';
        default = [ ];
        type = listOf (submodule [ rulesOptions ]);
      };

      tags = mkOption {
        description = "List of tag objects";
        default = [ ];
        type = listOf str;
      };

      remoteTraceTarget = mkOption {
        description = "10-digit ZeroTier ID of remote trace target";
        default = null;
        type = nullOr str;
      };

      remoteTraceLevel = mkOption {
        description = "Remote trace verbosity level";
        default = null;
        type = nullOr int;
      };

      members = mkOption {
        description = ''
          Network members
        '';
        default = null;
        type = nullOr (attrsOf (submodule [ memberOptions ]));
      };

    };
  };

  networksJson = with builtins;
    let
      mkMembersStr = net: members: (concatMapStrings
        (m: ''
          cat > $out/${cfg.networks."${net}".id}/${m}.json <<EOL
          ${toJSON (sanitize cfg.networks."${net}".members."${m}")}
          EOL
        '')
        (attrNames members));
    in
    pkgs.runCommandNoCC "zerotier-controller-networks" { } (''
      mkdir -p $out
    '' + (concatMapStrings
      (net: ''
        cat > $out/${cfg.networks."${net}".id}.json <<EOL
        ${toJSON (sanitize cfg.networks."${net}")}
        EOL
      '' + (optionalString (attrsets.isAttrs cfg.networks."${net}".members)
        (''
          mkdir -p $out/${cfg.networks."${net}".id}
        '' + (mkMembersStr net cfg.networks."${net}".members))))
      (attrNames cfg.networks)));

in

{
  options.services.zerotierone.controller = with types; {
    enable = mkEnableOption "ZeroTierOne Controller";
    networks = mkOption {
      description = "ZT Network config";
      default = { };
      type = attrsOf (submodule [ networkOptions ]);
    };
  };

  config = mkIf cfg.enable {
    services.zerotierone.enable = true;
    systemd.services.zerotierone = {
      preStart =
        let
          immutable_networks = attrNames (filterAttrs (n: v: v.mutable == false) cfg.networks);
          immutable_p = (lists.length immutable_networks) > 0;
        in
        mkIf immutable_p
          (concatMapStrings
            (str: ''
              rm -rf ${top.homeDir}/controller.d/network/${cfg.networks."${str}".id}{,.json}
            '')
            immutable_networks);

      postStart = with builtins; ''
        until nc -d -z 127.0.0.1 ${toString top.service_port};do sleep 2 && echo waiting for API && sleep 1;done
        auth_token=$(cat ${top.homeDir}/authtoken.secret)
        for net in $(ls -1 -d "${toPath networksJson}/"*.json)
        do
          net_id=''${net##*/}
          http -f POST http://127.0.0.1:${toString top.service_port}/controller/network/''${net_id%".json"} X-ZT1-Auth:\ $auth_token < $net &> /dev/null

          if [[ -d "${toPath networksJson}/''${net_id%".json"}" ]]
          then
            for member in $(ls -1 -d "${toPath networksJson}/''${net_id%".json"}/"*.json )
            do
              member_id=''${member##*/}
              http -f POST http://127.0.0.1:${toString top.service_port}/controller/network/''${net_id%".json"}/member/''${member_id%".json"} X-ZT1-Auth:\ $auth_token < $member &> /dev/null
            done
          fi
        done
      '';
    };

    environment.systemPackages =
      let
        scriptInit = ''
          set -e
          ADDRESS=$(zerotier-cli -j info | ${pkgs.jq}/bin/jq -r '.address')
          AUTH=$(cat ${top.homeDir}/authtoken.secret)
          BASEURL=http://127.0.0.1:${toString top.service_port}/controller/network
        '';
      in
      attrValues
        (
          mapAttrs'
            (net_name: net_cfg:
              nameValuePair "zerotier-network-${net_name}-${net_cfg.id}"
                (pkgs.writeShellScriptBin "zerotier-network-${net_name}-${net_cfg.id}" ''
                  set -e
                  auth_token=$(cat ${top.homeDir}/authtoken.secret)
                  url=http://127.0.0.1:${toString top.service_port}/controller/network/${net_cfg.id}/member/$1
                  tmpfile=/tmp/${net_name}-member-$1.json
                  cat > $tmpfile <<EOF
                  {"authorized": true, "ipAssignments": [ "$2" ]}
                  EOF
                  ${pkgs.httpie}/bin/http -f POST $url X-ZT1-Auth:\ $auth_token < $tmpfile &> /dev/null
                  rm -rf $tmpfile
                ''))
            cfg.networks) ++ [
        (pkgs.writeShellScriptBin "zerotier-network-create" ''
          ${scriptInit}
          ${pkgs.httpie}/bin/http --raw '{}' -f POST "''${BASEURL}/''${ADDRESS}______" X-ZT1-Auth:\ $AUTH
        '')
      ];
  };
}
