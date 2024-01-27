{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
with lib;
let
  isLightDM = config.services.xserver.displayManager.lightdm.enable;
  isHM = hasAttrByPath [ "home-manager" "sharedModules" ] config;
in
mkMerge [
  (mkIf isHM {
    home-manager.sharedModules = [
      ({ pkgs, ... }: {

        xdg.mimeApps.associations.added = {
          "x-scheme-handler/rdp" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/spice" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/vnc" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/remmina" = "org.remmina.Remmina.desktop";
          "application/x-remmina" = "org.remmina.Remmina.desktop";
        };

        xdg.mimeApps.defaultApplications = {
          "x-scheme-handler/rdp" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/spice" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/vnc" = "org.remmina.Remmina.desktop";
          "x-scheme-handler/remmina" = "org.remmina.Remmina.desktop";
          "application/x-remmina" = "org.remmina.Remmina.desktop";
        };

        home.packages = with pkgs;[
          remmina
          xorg.xorgserver
          nx-libs
        ];
      })
    ];
  })

  (mkIf isLightDM {
    services.xserver.displayManager.lightdm.extraConfig = ''
      [XDMCPServer]
      enabled=true
      port=177
    '';
  })
]
