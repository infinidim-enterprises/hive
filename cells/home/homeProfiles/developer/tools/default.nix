{ pkgs, lib, osConfig, ... }:
with lib;

mkMerge [
  {
    home.packages = with pkgs; [
      uefitool
      uefi-firmware-parser
    ];
  }

  (mkIf osConfig.services.xserver.displayManager.lightdm.enable {
    home.packages = with pkgs; [ dfeet bustle ];
  })
]
