{ inputs, cell, ... }:

{ lib, pkgs, ... }:

{
  # imports = [ profiles.virtualisation.docker ];

  # age.secrets."zerotier-controller" = {
  #   file = "${self}/secrets/shared/zerotier-controller.age";
  #   mode = "0600";
  #   path = "/run/secrets/zerotier-controller.identity.secret";
  # };
  networking.firewall.allowedTCPPorts = [ 9993 ];

  services.zerotierone.enable = true;
  services.zerotierone.controller.enable = true;

  services.zerotierone.controller.networks.admin =
    let pref = "10.0.1"; in
    {
      id = "d3b09dd7f50e3236";
      mutable = false;
      name = "Admin network - admin.njk.local";
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

}
