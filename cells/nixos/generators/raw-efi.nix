{ config, lib, pkgs, modulesPath, ... }:
{
  # for virtio kernel drivers
  imports = [ "${toString modulesPath}/profiles/qemu-guest.nix" ];

  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };


  boot.growPartition = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  # boot.initrd.availableKernelModules = [ "uas" "zfs" ] ++ config.boot.initrd.availableKernelModules;
  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [ "uas" ];

  system.build.raw = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    name = "install-" + config.networking.hostName;
    diskSize = "auto";
    # additionalSpace = "512M";
    memSize = 1024 * 16;
    format = "raw";
    bootSize = "512M";
    # touchEFIVars = true;
    partitionTableType = "efi";
  };

  formatAttr = "raw";
  filename = "*.img";
}
