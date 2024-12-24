{ inputs, cell, ... }:

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      cell.nixosProfiles.hardware.common
      "${toString modulesPath}/profiles/qemu-guest.nix"
    ];

  system.nixos.label = baseNameOf ./.;
  system.nixos.versionSuffix = "_cloud";

  boot.growPartition = true;
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0"
    "nvme.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/sda";

  boot.loader.grub.efiSupport = false;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.timeout = 0;
}
