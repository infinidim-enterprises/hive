{ inputs, cell, ... }:

{ pkgs, ... }:
{
  services.transmission.enable = true;
  services.transmission.package = pkgs.transmission_4;
  services.transmission.settings = {
    # webHome = inputs.cells.common.packages.transmissionic;
    # download-dir
  };

  services.udev.extraRules = ''
    # Start services when the "torrents" disk is attached
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="torrents", TAG+="systemd", ENV{SYSTEMD_WANTS}="minidlna.service transmission.service"

    # Stop services when the "torrents" disk is removed
    ACTION=="remove", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="torrents", RUN+="${pkgs.systemd}/bin/systemctl stop minidlna.service transmission.service"

  '';

  systemd.services.transmission.environment.TRANSMISSION_WEB_HOME = inputs.cells.common.packages.transmissionic;
}
