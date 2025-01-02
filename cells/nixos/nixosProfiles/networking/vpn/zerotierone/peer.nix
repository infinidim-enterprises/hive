{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [ cell.nixosModules.services.networking.zerotierone.default ];

  services.zerotierone.enable = true;
  services.zerotierone.package = inputs.cells.common.packages.zerotierone;
  services.zerotierone.joinNetworks = [{ "a84ac5c10a162ba4" = "Mobiles"; }];
}
