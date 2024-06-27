{ inputs, cell, ... }:

{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.disabledPlugins = [ "GameControllerWakelock" ];

  services.blueman.enable = true;
  environment.systemPackages = [ pkgs.pavucontrol ];
}
