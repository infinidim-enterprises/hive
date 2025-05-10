{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  filteredStylix = import (inputs.nix-filter.lib.filter {
    # ISSUE: https://github.com/danth/stylix/issues/47
    # NOTE: I don't use gnome
    root = inputs.stylix.outPath;
    exclude = [
      "modules/gnome"
      "modules/nixos-icons"
    ];
  });
in

{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkIf
    mkMerge
    hasAttr;

  fontPkg = pkgs.nerdfonts.override (_: {
    fonts = [
      "InconsolataLGC"
      "Ubuntu"
      "DejaVuSansMono"
      "DroidSansMono"
      "JetBrainsMono"
      "ShareTechMono"
      "UbuntuMono"
      "VictorMono"
    ];
  });

in

{
  imports = [ filteredStylix.nixosModules.stylix ];
  options.programs = { };
  config = mkMerge [
    (mkIf (hasAttr "home-manager" config) {
      home-manager.sharedModules = [
        {
          stylix.targets.gtk.enable = config.stylix.targets.gtk.enable;
        }
      ];
    })
    {
      ### stylix targets:
      # stylix.targets.lightdm.enable = false; # Only changes the background image
      # stylix.targets.gtk.enable = true;
      ###

      stylix.enable = true;
      stylix.autoEnable = false;

      stylix.polarity = "dark";
      stylix.image = "${pkgs.nixos-icons}/share/icons/hicolor/1024x1024/apps/nix-snowflake.png";

      stylix.cursor.name = "Numix-Cursor-Light";
      stylix.cursor.package = pkgs.numix-cursor-theme;
      stylix.cursor.size = 32;

      stylix.fonts.serif.package = fontPkg;
      stylix.fonts.serif.name = "UbuntuMono Nerd Font Mono";
      stylix.fonts.sansSerif.package = fontPkg;
      stylix.fonts.sansSerif.name = "UbuntuMono Nerd Font Mono";
      stylix.fonts.monospace.package = fontPkg;
      stylix.fonts.monospace.name = "UbuntuMono Nerd Font Mono";
      stylix.fonts.emoji.package = fontPkg;
      stylix.fonts.emoji.name = "UbuntuMono Nerd Font Mono";

      stylix.fonts.sizes.desktop = 10;
      stylix.fonts.sizes.applications = 12;
      stylix.fonts.sizes.terminal = 12;
      stylix.fonts.sizes.popups = 10;

      /*

      */
    }
  ];
}
