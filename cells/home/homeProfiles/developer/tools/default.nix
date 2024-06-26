{ pkgs, lib, osConfig, localLib, ... }:
with lib;

mkMerge [
  {
    home.packages = with pkgs; [
      uefitool
      uefi-firmware-parser
    ];
  }

  (mkIf (localLib.isGui osConfig) {
    home.packages = with pkgs; [ d-spy bustle ];
  })
]
