{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge;
in
{
  imports = [ cell.nixosModules.services.networking.zerotierone.default ];

  config = mkMerge [
    {
      services.zerotierone.enable = true;
      services.zerotierone.package = inputs.cells.common.packages.zerotierone;
      services.zerotierone.joinNetworks = [
        { "ba8ec53f7acfdaa1" = "admin"; } # NOTE: self-hosted controller
        # { "a84ac5c10a162ba4" = "mobiles"; } # NOTE: zt-central network
      ];
    }

    (mkIf (! config.services.zerotierone.controller.enable) {
      # NOTE: self-hosted with ddns/dhcp/ipxe
      # join the peer, unless it's the controller
      services.zerotierone.joinNetworks = [{ "ba8ec53f7ab4e74f" = "njk.local"; }];
    })
  ];
}
