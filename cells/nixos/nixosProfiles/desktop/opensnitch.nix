{ config, lib, pkgs, ... }:

lib.mkMerge [
  {
    services.opensnitch.enable = true;
    services.opensnitch.settings.ProcMonitorMethod = "ebpf";
  }
  (lib.mkIf (config ? home-manager) {
    home-manager.sharedModules = [{ services.opensnitch-ui.enable = true; }];
  })
]
