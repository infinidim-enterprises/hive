{ inputs, cell, ... }:

{ self, config, profiles, containers, lib, pkgs, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.zerotier-controller;
  # localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;

  members = {
    # eadrax
    "3d806c5763".authorized = true;
    "3d806c5763".activeBridge = true;

    "09eb0880cf".authorized = true;
    "09eb0880cf".activeBridge = true;

    "fc9dbaf872".authorized = true;
    "fc9dbaf872".activeBridge = true;

    # gateway-container
    "b4ff4d6054".authorized = true;
    "b4ff4d6054".activeBridge = true;

    # dhcp-boot
    "9f58dd7dc4".authorized = true;
    "9f58dd7dc4".activeBridge = true;
  };
in
{
  age.secrets."zerotier-controller" = {
    file = "${self}/secrets/shared/zerotier-controller.age";
    mode = "0600";
    path = "/run/secrets/zerotier-controller.identity.secret";
  };

  containers."${namespace}-zerotier-controller" = {

    bindMounts.zerotier-id.hostPath = "/run/secrets/zerotier-controller.identity.secret";
    bindMounts.zerotier-id.mountPoint = "/var/lib/zerotier-one/identity.secret";
    bindMounts.zerotier-id.isReadOnly = true;

    inherit (lan) macvlans;
    timeoutStartSec = "120s";
    autoStart = true;
    ephemeral = true;
    enableTun = true;
    config =
      {
        imports = containers.systemd;

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        networking.hostName = "zerotier-controller";
        networking.domain = lan.domain;

        networking.firewall.allowedTCPPorts = [ 9993 ];

        services.zerotierone.enable = true;
        services.zerotierone.controller.enable = true;

        services.zerotierone.controller.networks.installs = {
          inherit members;
          id = "d3b09dd7f53d1214";
          mutable = false;
          name = "ISC-KEA-DHCP - Installs";
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
        };

        services.zerotierone.controller.networks.admin-kea = {
          inherit members;
          id = "d3b09dd7f51f90df";
          mutable = false;
          name = "ISC-KEA-DHCP - Admin Services";
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
        };

        services.zerotierone.controller.networks.k3s = {
          inherit members;
          id = "d3b09dd7f58387ff";
          mutable = false;
          name = "k3s self-managed";
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
        };

        services.zerotierone.controller.networks.admin-zt =
          let pref = "10.12.0"; in
          {
            id = "d3b09dd7f50e3236";
            mutable = false;
            name = "Zeronsd - Admin Services";
            ipAssignmentPools = [{ ipRangeStart = "${pref}.100"; ipRangeEnd = "${pref}.200"; }];
            routes = [{ target = "${pref}.0/24"; }];
            members = {
              "3d806c5763".authorized = true;
              "3d806c5763".activeBridge = true;
              "3d806c5763".ipAssignments = [ "${pref}.220" ];

              "09eb0880cf".authorized = true;
              "09eb0880cf".activeBridge = true;
              "09eb0880cf".ipAssignments = [ "${pref}.254" ];

              "fc9dbaf872".authorized = true;
              "fc9dbaf872".activeBridge = true;
              "fc9dbaf872".ipAssignments = [ "${pref}.222" ];
            };
          };
      };
  };
}
