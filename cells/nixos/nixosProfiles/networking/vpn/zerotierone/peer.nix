{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [ cell.nixosModules.services.networking.zerotierone.default ];

  services.zerotierone.enable = true;
}
