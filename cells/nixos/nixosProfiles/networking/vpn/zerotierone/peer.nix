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

    (mkIf config.services.adguardhome.enable {
      services.adguardhome.settings.dns = {
        use_private_ptr_resolvers = true;
        upstream_dns = [ "[/njk.local/192.168.121.1:53]" ];
        local_ptr_upstreams = [ "[/121.168.192.in-addr.arpa/192.168.121.1:53]" ];
      };
    })

    (mkIf ((! config.services.zerotierone.controller.enable) && config.services.resolved.enable) {
      services.resolved.domains = [ "njk.local" ];
    })

    (mkIf (! config.services.zerotierone.controller.enable) {
      # NOTE: self-hosted with ddns/dhcp/ipxe
      # join the peer, unless it's the controller
      services.zerotierone.joinNetworks = [{ "ba8ec53f7ab4e74f" = "njk.local"; }];
    })
  ];
}
