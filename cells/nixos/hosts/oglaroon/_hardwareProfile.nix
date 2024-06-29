{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  deploy.params.cpu = "amd";
  deploy.params.gpu = "amd";
  deploy.params.ram = 64;
  # deploy.params.zfsCacheMax = 8;

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "nvme_core.default_ps_max_latency_us=0" # NOTE: possibly a workaround for shitty Crucial nvme drive
  ];

  disko.devices = cell.diskoConfigurations.oglaroon { inherit lib; };
  imports =
    [
      # TODO: cell.nixosProfiles.hardware.rtw89
      # cell.nixosProfiles.boot.systemd-grub-zfs

      inputs.disko.nixosModules.disko

      cell.nixosProfiles.hardware.amd
      cell.nixosProfiles.hardware.opengl
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-boot
      cell.nixosProfiles.filesystems.impermanence.default
    ];
}
