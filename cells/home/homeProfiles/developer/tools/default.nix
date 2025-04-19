{ pkgs, lib, osConfig, localLib, ... }:
with lib;

mkMerge [
  {
    home.packages = with pkgs; [
      uefitool
      uefi-firmware-parser
      # TODO: package https://github.com/darrenburns/postings
    ];
  }

  (mkIf (localLib.isGui osConfig) {
    home.packages = with pkgs; [ d-spy bustle ];
  })
]
