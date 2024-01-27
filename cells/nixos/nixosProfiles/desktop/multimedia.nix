{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
with lib;

mkIf (config.services.xserver.displayManager.lightdm.enable && config.hardware.bluetooth.enable) (mkMerge [{
  environment.systemPackages = [ pkgs.blueman ];
}])
