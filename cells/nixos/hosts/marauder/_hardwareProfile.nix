{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  # NOTE: https://askubuntu.com/questions/1418992/sgx-disabled-by-bios-message-on-ubuntu-20-04-booting
  boot.kernelParams = [ "nosgx" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];

  boot.loader.efi.canTouchEfiVariables = false;

  # fileSystems = lib.mkDefault {
  #   "/" = {
  #     device = "/dev/disk/by-label/nixos";
  #     autoResize = true;
  #     fsType = "ext4";
  #   };
  # };

  # boot.growPartition = lib.mkDefault true;

  # boot.kernelParams = [ "console=ttyS0" ];
  # boot.loader.grub.device =
  #   if (pkgs.stdenv.system == "x86_64-linux") then
  #     (lib.mkDefault "/dev/vda")
  #   else
  #     (lib.mkDefault "nodev");

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  # disko.rootMountPoint = "/mnt/install";

  imports =
    [
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs

      ###
      inputs.disko.nixosModules.disko
      cell.nixosProfiles.boot.systemd-boot
    ];
}
