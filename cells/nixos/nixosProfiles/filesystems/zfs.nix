{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
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

  systemd.shutdownRamfs.enable = true;
  systemd.shutdownRamfs.contents = {
    "/lib/systemd/system-shutdown/zpool-sync-shutdown".source =
      pkgs.writeShellScript "zpool" ''
        pools=$(${pkgs.zfs}/bin/zpool list -H -o name)

        for pool in $pools; do
          ${pkgs.zfs}/bin/zpool export "$pool"
        done

        exec ${pkgs.zfs}/bin/zpool sync
      '';
  };

  boot.kernelParams = [ "zfs_force=1" ] ++
    lib.optional
      (cell.lib.isZfs config && config.deploy.params.zfsCacheMax != null)
      "zfs.zfs_arc_max=${config.deploy.params.zfsCacheMax}";
}
