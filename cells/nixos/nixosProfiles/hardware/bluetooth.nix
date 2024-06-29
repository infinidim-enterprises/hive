{ inputs, cell, ... }:

{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.disabledPlugins = [
    "bap"
    "bass"
    "mcp"
    "vcp"
    "micp"
    "ccp"
    "csip"
    "GameControllerWakelock"
  ];

  services.blueman.enable = true;
  environment.systemPackages = [ pkgs.pavucontrol ];
}
