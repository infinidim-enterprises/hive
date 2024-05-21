{ inputs, cell, ... }:

{ config, lib, ... }:
{
  boot.kernel.sysctl."vm.swappiness" = 1;

  boot.zfs.allowHibernation = lib.mkDefault true;
  boot.zfs.forceImportAll = lib.mkDefault false;
  boot.zfs.forceImportRoot = lib.mkDefault false;

  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  networking.hostId = lib.mkDefault (abort "ZFS requires networking.hostId to be set");

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';
  boot.kernelParams =
    lib.optional
      (cell.lib.isZfs config && config.deploy.params.zfsCacheMax != null)
      "zfs.zfs_arc_max=${config.deploy.params.zfsCacheMax}";
}
