{ inputs, cell, ... }:

{ config, lib, pkgs, modulesPath, ... }:
{
  # TODO: https://xanmod.org/ pkgs.linuxPackages_xanmod
  boot.kernelPackages = pkgs.linuxPackages;
  deploy.params.cpu = "amd";
  deploy.params.gpu = "amd";
  deploy.params.ram = 64;

  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];
  boot.kernelParams = [ "amdgpu.sg_display=0" ];
  # disko.devices = cell.diskoConfigurations.oglaroon { inherit lib; };

  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  boot.growPartition = lib.mkDefault true;
  # boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device =
    if (pkgs.stdenv.system == "x86_64-linux") then
      (lib.mkDefault "/dev/vda")
    else
      (lib.mkDefault "nodev");

  imports =
    [
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.core.kernel.physical-access-system
      # cell.nixosProfiles.filesystems.zfs
      # cell.nixosProfiles.boot.systemd-grub-zfs
      # inputs.disko.nixosModules.disko
    ];
}
