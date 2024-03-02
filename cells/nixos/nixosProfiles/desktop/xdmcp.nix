{ inputs, cell, ... }:

{ config, lib, ... }:
lib.mkMerge [
  (mkIf config.services.xserver.displayManager.lightdm.enable {
    services.xserver.displayManager.lightdm.extraConfig = ''
      [XDMCPServer]
      enabled=true
      port=177
    '';
  })
]
