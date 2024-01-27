{ inputs, cell, ... }:

{ config, lib, ... }:
let
  inherit (lib) mkIf versionOlder;
  oldRelease = versionOlder config.system.stateVersion "22.11";
in
mkIf oldRelease
{ hardware.video.hidpi.enable = true; }
