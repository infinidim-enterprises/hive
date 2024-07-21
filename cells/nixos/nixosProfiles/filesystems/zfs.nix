{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  boot.kernel.sysctl."vm.swappiness" = 1;

  boot.zfs.package = with config.boot.kernelPackages;
    if (zfs.meta.broken && zfs_unstable.meta.broken)
    then (abort "kernel v${kernel.version} has no zfs userland!")
    else
      if zfs.meta.broken
      then pkgs.zfs_unstable
      else pkgs.zfs;

  # NOTE: Multiple issues with zfs and hibernation:
  # https://github.com/openzfs/zfs/issues/12842
  # https://github.com/openzfs/zfs/issues/260
  # TODO: once merged, allows semi-safe hibernation - https://github.com/NixOS/nixpkgs/pull/208037
  boot.zfs.allowHibernation = false;
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  services.fstrim.enable = false;
  services.zfs.trim.enable = false;
  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "daily";

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

  boot.kernelParams = [
    # "zfs_force=1"
    "rd.luks.allow-discards"
  ] ++
  lib.optional
    (cell.lib.isZfs config && config.deploy.params.zfsCacheMax != null)
    "zfs.zfs_arc_max=${config.deploy.params.zfsCacheMax}";
}
