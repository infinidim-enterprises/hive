{ pkgs, osConfig, localLib, lib, ... }:

{
  services.kbfs.enable = true;
  services.keybase.enable = true;

  systemd.user.services = {
    # TODO: disable debug loglevel on kbfs/keybase
    kbfs.Service.StandardOutput = "null";
    keybase.Service.StandardOutput = "null";
  };

  # FIXME: keybase-gui doesn't seem to have a desktop file and isn't on path either!
  home.packages = lib.mkIf (localLib.isGui osConfig) [ pkgs.keybase-gui ];
}
