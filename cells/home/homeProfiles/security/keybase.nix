{ pkgs, osConfig, localLib, lib, ... }:

{
  services.kbfs.enable = true;
  services.keybase.enable = true;

  systemd.user.services = {
    kbfs.Service.StandardOutput = "null";
    keybase.Service.StandardOutput = "null";
  };

  home.packages = lib.mkIf (localLib.isGui osConfig) [ pkgs.keybase-gui ];
}
