{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
with lib;

mkIf ((cell.lib.isGui config) && config.hardware.bluetooth.enable) (mkMerge [{
  environment.systemPackages = [ pkgs.blueman ];
}])
