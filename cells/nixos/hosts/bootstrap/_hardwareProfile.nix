{ inputs, cell, ... }:

{ config, lib, pkgs, modulesPath, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  # deploy.params.cpu = "amd";
  # deploy.params.gpu = "amd";
  # deploy.params.ram = 64;

  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];

  # boot.initrd.systemd.package
  # boot.initrd.services.udev.packages
  #

  security.tpm2.enable = true;
  # security.tpm2.abrmd.enable = true;
  environment.systemPackages = with pkgs; [
    tpm2-abrmd
    tpm2-tools
    tpm2-openssl
    tpm2-pkcs11
    tpm2-totp
    tpm2-tss
    # tpmmanager
  ];

  boot.initrd.systemd.managerEnvironment.SYSTEMD_LOG_LEVEL = "debug";

  boot.kernelParams = [
    "udev.log_level=debug"

  ];

  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  # boot.growPartition = lib.mkDefault true;
  # boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = lib.mkIf config.boot.loader.grub.enable (lib.mkDefault "nodev");
  # if (pkgs.stdenv.system == "x86_64-linux") then
  #   (lib.mkDefault "/dev/vda")
  # else
  #   (lib.mkDefault "nodev");

  imports =
    [
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
    ];
}
