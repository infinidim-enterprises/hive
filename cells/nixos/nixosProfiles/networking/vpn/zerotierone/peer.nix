{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [ cell.nixosModules.services.networking.zerotierone.default ];

  services.zerotierone.enable = true;
  services.zerotierone.package = inputs.cells.common.packages.zerotierone;
  services.zerotierone.joinNetworks = [
    { "ba8ec53f7acfdaa1" = "admin"; }
    { "a84ac5c10a162ba4" = "mobiles"; }
  ];
}
