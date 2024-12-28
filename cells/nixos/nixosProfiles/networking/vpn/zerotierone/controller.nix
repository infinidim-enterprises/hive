{ inputs, cell, ... }:

{ lib, pkgs, ... }:

{
  # imports = [ profiles.virtualisation.docker ];

  # age.secrets."zerotier-controller" = {
  #   file = "${self}/secrets/shared/zerotier-controller.age";
  #   mode = "0600";
  #   path = "/run/secrets/zerotier-controller.identity.secret";
  # };

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
        /*
            containers = {
              systemd = suites.networking ++ [
                self.nixosModules.zerotierone
                self.nixosModules.deploy
                self.inputs.agenix.nixosModules.age
                self.inputs.home.nixosModules.home-manager
                {
                  nixpkgs.config.allowUnfree = true;
                  # nixpkgs.overlays = [ nixLatest.overlay ];
                  nix.extraOptions = ''
                    extra-experimental-features = nix-command flakes
                  '';
                }
                { services.openssh.enable = false; }
                ({ lib, ... }: { deploy.params.lan.dhcpClient = lib.mkDefault true; })
                ({ pkgs, ... }: { environment.systemPackages = with pkgs; [ tcpdump vim ]; })
              ];
            };

        */
        # imports = containers.systemd;
        services.openssh.enable = lib.mkForce false;

        environment.systemPackages = [ pkgs.oq ];

        systemd.network.networks.lan.dhcpV4Config.ClientIdentifier = "mac";
        systemd.network.networks.lan.linkConfig.MACAddress = "00:F7:77:00:1a:ff";

        networking.firewall.allowedTCPPorts = [ 9993 ];

        services.zerotierone.enable = true;
        services.zerotierone.controller.enable = true;

        services.zerotierone.controller.networks.admin =
          let pref = "10.0.0"; in
          {
            id = "d3b09dd7f50e3236";
            mutable = false;
            name = "Admin network - njk.local";
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
