{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkMerge;
in
mkMerge [
  {
    home.packages = with pkgs; [ jmtpfs dconf ];

    xdg.enable = mkDefault true;
    xdg.mime.enable = mkDefault true;
    xdg.mimeApps.enable = mkDefault true;
    xdg.userDirs.enable = mkDefault true;
    xdg.userDirs.createDirectories = mkDefault true;
  }
]
