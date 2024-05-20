{ inputs, cell, ... }:

{ config, lib, pkgs, modulesPath, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  # deploy.params.cpu = "amd";
  # deploy.params.gpu = "amd";
  # deploy.params.ram = 64;

  # NOTE: https://askubuntu.com/questions/1418992/sgx-disabled-by-bios-message-on-ubuntu-20-04-booting
  boot.kernelParams = [ "nosgx" ];

  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];
  # boot.kernelParams = [ "amdgpu.sg_display=0" ];

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
