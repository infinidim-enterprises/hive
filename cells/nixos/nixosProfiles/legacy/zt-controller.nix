{ inputs, cell, ... }:

{ self, suites, profiles, containers, lib, pkgs, ... }:

{
  imports = [ profiles.virtualisation.docker ];

  age.secrets."zerotier-controller" = {
    file = "${self}/secrets/shared/zerotier-controller.age";
    mode = "0600";
    path = "/run/secrets/zerotier-controller.identity.secret";
  };

  containers.zerotier-controller = {

    bindMounts.zerotier-id.hostPath = "/run/secrets/zerotier-controller.identity.secret";
    bindMounts.zerotier-id.mountPoint = "/var/lib/zerotier-one/identity.secret";
    bindMounts.zerotier-id.isReadOnly = true;

    additionalCapabilities = [
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_BROADCAST"
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
      "CAP_SYS_ADMIN"
    ];

    timeoutStartSec = "120s";
    macvlans = [ "lan" ];
    autoStart = true;
    ephemeral = true;
    enableTun = true;
    config =
      {
        imports = containers.systemd;
        services.openssh.enable = lib.mkForce false;

        environment.systemPackages = [ pkgs.oq ];

        systemd.network.networks.lan.dhcpV4Config.ClientIdentifier = "mac";
        networking.firewall.allowedTCPPorts = [ 9993 ];

        services.zerotierone.enable = true;
        services.zerotierone.controller.enable = true;

        services.zerotierone.controller.networks.installs = {
          id = "d3b09dd7f53d1214";
          mutable = false;
          name = "ISC-KEA-DHCP - Installs";
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
          members = {
            "3d806c5763".authorized = true;
            "3d806c5763".activeBridge = true;

            "09eb0880cf".authorized = true;
            "09eb0880cf".activeBridge = true;
          };
        };

        services.zerotierone.controller.networks.admin-kea = {
          id = "d3b09dd7f51f90df";
          mutable = false;
          name = "ISC-KEA-DHCP - Admin Services";
          v4AssignMode = "none";
          rules = [{ type = "ACTION_ACCEPT"; }];
          multicastLimit = 254;
          members = {
            "3d806c5763".authorized = true;
            "3d806c5763".activeBridge = true;

            "09eb0880cf".authorized = true;
            "09eb0880cf".activeBridge = true;
          };
        };

        services.zerotierone.controller.networks.admin-zt =
          let pref = "10.44.44"; in
          {
            id = "d3b09dd7f50e3236";
            mutable = false;
            name = "Zeronsd - Admin Services";
            ipAssignmentPools = [{ ipRangeStart = "${pref}.100"; ipRangeEnd = "${pref}.200"; }];
            routes = [{ target = "${pref}.0/24"; }];
            members = {
              "3d806c5763".authorized = true;
              "3d806c5763".activeBridge = true;
              "3d806c5763".ipAssignments = [ "${pref}.44" ];

              "09eb0880cf".authorized = true;
              "09eb0880cf".activeBridge = true;
              "09eb0880cf".ipAssignments = [ "${pref}.254" ];
            };

            # members =
            #   mapAttrs'
            #     (n: v:
            #       (nameValuePair
            #         (zt_key v.zerotier.privateKey).id
            #         ({ authorized = true; } //
            #           (optionalAttrs (hasAttr "ip" v.zerotier.admin) { ipAssignments = [ v.zerotier.admin.ip ]; }) //
            #           (optionalAttrs (hasAttr "activeBridge" v.zerotier.admin) { activeBridge = v.zerotier.admin.activeBridge; }))
            #       ))
            #     hosts;
          };
      };
  };

  # virtualisation.oci-containers.backend = "docker";
  # virtualisation.oci-containers.containers.mfc-j615w-printing = {
  #   autoStart = true;
  #   image = "njkli/mfc-j615w";
  #   imageFile = pkgs.dockerTools.pullImage {
  #     imageName = "njkli/mfc-j615w";
  #     imageDigest = "sha256:0b64b5a02d642d4bc3b084d04a2667fd7d42699c51ebd84abc00e13019ce5b6b";
  #     sha256 = "00l17n69zlpl7hq36jmnxc7sqcpg9yfxyyq7p3fgy82hisdglw52";
  #   };
  #   volumes = [
  #     "/sys/fs/cgroup:/sys/fs/cgroup"
  #   ];
  #   extraOptions = [
  #     "--tmpfs=/tmp"
  #     "--tmpfs=/run"
  #     "--tmpfs=/run/lock:rw"
  #   ];
  #   ports = [ "631:631/tcp" ];
  # };
  # networking.firewall.allowedTCPPorts = [ 631 ];

}
