{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  imports =
    [
      { boot.growPartition = true; }
      cell.nixosProfiles.hardware.common
    ];
}
