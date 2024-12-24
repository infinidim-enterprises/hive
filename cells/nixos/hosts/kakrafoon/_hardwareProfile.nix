{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  imports =
    [
      {
        boot.growPartition = true;
        boot.kernelParams = [
          # "force_addr=0xaddr"
          "console=tty1"
          "nvme.shutdown_timeout=10"
          "libiscsi.debug_libiscsi_eh=1"
          "crash_kexec_post_notifiers"
          # "loglevel=7"
        ];
      }
      cell.nixosProfiles.hardware.common
    ];
}
