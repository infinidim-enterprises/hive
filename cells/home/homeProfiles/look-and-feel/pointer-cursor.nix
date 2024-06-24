{ pkgs, lib, config, localLib, osConfig, ... }:
let
  inherit (localLib) isGui;
  inherit (lib) mkMerge mkIf;
in
mkMerge [
  (mkIf (isGui osConfig) {
    home.pointerCursor.x11.enable = true;
    home.pointerCursor.name = "Numix-Cursor-Light";
    home.pointerCursor.size = 32;
    home.pointerCursor.package = pkgs.numix-cursor-theme;

    dconf.settings."org/mate/desktop/peripherals/mouse".cursor-size = 32;
    dconf.settings."org/mate/desktop/peripherals/mouse".cursor-theme = "Numix-Cursor-Light";
  })

  (mkIf (!config.wayland.windowManager.hyprland.enable) {
    services.unclutter.enable = true;
    services.unclutter.timeout = 3;
  })
]
