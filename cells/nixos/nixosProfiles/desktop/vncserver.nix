{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

lib.mkMerge [
  (lib.mkIf config.services.xserver.displayManager.lightdm.enable {
    # systemd.services.display-manager.path = [ pkgs.tigervnc ];
    services.xserver.displayManager.lightdm.extraConfig = ''
      [VNCServer]
      enabled=true
      command=${pkgs.tigervnc}/bin/Xvnc -SecurityTypes None
      port=44444
      listen-address=0.0.0.0
      width=1920
      height=1080
      depth=24
    '';
  })
]
