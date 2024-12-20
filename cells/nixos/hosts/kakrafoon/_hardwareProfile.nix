{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  imports =
    [
      {
        boot.growPartition = true;
        boot.kernelParams = [ "force_addr=0xaddr" "loglevel=7" ];
      }
      cell.nixosProfiles.hardware.common
    ];
}
