{ pkgs, lib, osConfig, ... }:
with lib;
mkMerge [
  (mkIf osConfig.services.xserver.enable {
    # home.pointerCursor.x11.enable = true;
    # home.pointerCursor.name = "Numix-Cursor-Light";
    # home.pointerCursor.size = 32;
    # home.pointerCursor.package = pkgs.numix-cursor-theme;

    services.unclutter.enable = true;
    services.unclutter.timeout = 3;

    dconf.settings."org/mate/desktop/peripherals/mouse".cursor-size = 32;
    dconf.settings."org/mate/desktop/peripherals/mouse".cursor-theme = "Numix-Cursor-Light";
  })
]
