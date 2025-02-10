{ inputs, cell, ... }:
let inherit (cell.lib) isGui; in

{ config, lib, pkgs, ... }:
let inherit (lib) mkMerge mkIf; in

mkMerge [
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
  }

  (mkIf (isGui config) {
    services.blueman.enable = true;
  })
]
