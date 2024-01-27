{ inputs, cell, ... }:

{ pkgs, ... }:

{
  hardware.bluetooth.package = pkgs.bluez5-experimental;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.disabledPlugins = [ "sap" ];

  services.blueman.enable = true;
  environment.systemPackages = [ pkgs.pavucontrol ];
}
