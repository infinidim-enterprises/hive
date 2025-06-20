{ inputs, cell, ... }:

{ config, lib, ... }:
let
  inherit (lib) mkMerge mkIf;
in

mkMerge [
  (mkIf (!config.systemd.oomd.enable) {
    services.earlyoom.enable = false;
    systemd.services.earlyoom.after = [ "swap.target" ];
  })

  (mkIf
    (
      config.swapDevices != [ ] &&
      config.systemd.enableCgroupAccounting &&
      config.systemd.oomd.enable
    )

    {
      systemd.services.systemd-oomd.after = [ "swap.target" ];
      systemd.oomd.extraConfig.DefaultMemoryPressureLimit = "85%";
      systemd.oomd.enableRootSlice = true;
      systemd.oomd.enableUserSlices = true;
    })
]
