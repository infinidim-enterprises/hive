{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  filteredStylix = import (inputs.nix-filter.lib.filter {
    # BUG: https://github.com/danth/stylix/issues/47
    # NOTE: I don't use gnome
    root = inputs.stylix.outPath;
    exclude = [
      "modules/gnome"
      "modules/nixos-icons"
    ];
  });
in

{ config, lib, pkgs, ... }:

{
  imports = [ filteredStylix.nixosModules.stylix ];
  options.programs = { };
  config = {
    stylix.enable = true;
    stylix.autoEnable = false;
    stylix.image = "${pkgs.nixos-icons}/share/icons/hicolor/1024x1024/apps/nix-snowflake.png";
    stylix.polarity = "dark";
    stylix.cursor.name = "Numix-Cursor-Light";
    stylix.cursor.package = pkgs.numix-cursor-theme;
    stylix.cursor.size = 32;
  };
}
