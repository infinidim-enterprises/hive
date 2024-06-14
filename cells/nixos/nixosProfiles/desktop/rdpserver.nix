{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
/*
   xrdp_vnc_ini = ''
   [vnc]
   name=LightDM_KillDisconnected
   lib=libvnc.so
   username=ask
   password=ask
   ip=127.0.0.1
   port=44444
   disconnect-timeout=0
   session-timeout=0
   '';
   echo '${xrdp_vnc_ini}' >> $out/xrdp.ini
*/
lib.mkMerge [
  (lib.mkIf config.services.xserver.displayManager.lightdm.enable {
    systemd.services.display-manager.path = [ pkgs.tigervnc ];
    services.xserver.displayManager.lightdm.extraConfig = ''
      [VNCServer]
      enabled=true
      command=Xvnc -SecurityTypes None
      port=44444
      listen-address=127.0.0.1
      width=1920
      height=1080
      depth=24
    '';

    sops.secrets.xrdp-password = {
      key = "xrdp-password";
      sopsFile = ../../../secrets/sops/nixos-common.yaml;
      neededForUsers = true;
    };

    # TODO: disable rdp port, allow only ssh port forwarding!
    networking.firewall.allowedTCPPorts = [ 3389 ];

    containers.xrdp.autoStart = true;
    containers.xrdp.ephemeral = true; # NOTE: Journal will not link to host
    containers.xrdp.additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    containers.xrdp.bindMounts.user-passwd.mountPoint = config.sops.secrets.xrdp-password.path;
    containers.xrdp.bindMounts.user-passwd.hostPath = config.sops.secrets.xrdp-password.path;
    containers.xrdp.bindMounts.user-passwd.isReadOnly = true;
    containers.xrdp.config = { pkgs, ... }: {
      system.stateVersion = config.bee.pkgs.lib.trivial.release;
      users.users.rdp.hashedPasswordFile = config.sops.secrets.xrdp-password.path;
      users.users.rdp.isNormalUser = true;

      services.xrdp.enable = true;
      services.xrdp.audio.enable = true;
      services.xrdp.defaultWindowManager =
        let
          vnc = pkgs.writeShellApplication {
            name = "connect2lightdm";
            runtimeInputs = with pkgs; [ tigervnc ];
            text = ''
              vncviewer -FullScreen \
                -FullscreenSystemKeys \
                -PreferredEncoding raw \
                -NoJpeg \
                127.0.0.1::44444
            '';
          };
        in
        "${vnc}/bin/connect2lightdm";
      services.xrdp.extraConfDirCommands = ''
        substituteInPlace $out/xrdp.ini \
          --replace "name=Xorg" "name=LightDM"
      '';
    };
  })
]
