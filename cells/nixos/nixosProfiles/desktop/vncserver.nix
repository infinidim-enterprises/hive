{ inputs, cell, ... }:

{ config, lib, ... }:

lib.mkMerge [
  (lib.mkIf config.services.xserver.displayManager.lightdm.enable {
    services.xserver.displayManager.lightdm.extraConfig = ''
      [VNCServer]
      enabled=true
      command=Xvnc -SecurityTypes None
      port=44444
      listen-address=0.0.0.0
      width=1920
      height=1080
      depth=24
    '';
  })
]
