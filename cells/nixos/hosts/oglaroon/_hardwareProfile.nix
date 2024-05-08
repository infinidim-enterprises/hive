{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  deploy.params.cpu = "amd";
  deploy.params.gpu = "amd";
  deploy.params.ram = 64;
  # deploy.params.zfsCacheMax = 8;

  # services.xserver.videoDrivers = [ "amdgpu" ];
  # hardware.opengl.extraPackages = [ pkgs.rocm-opencl-icd ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "nvme_core.default_ps_max_latency_us=0" # NOTE: possibly a workaround for shitty Crucial nvme drive
  ];
  disko.devices = cell.diskoConfigurations.oglaroon { inherit lib; };
  imports =
    [
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.hardware.amd
      cell.nixosProfiles.core.kernel.physical-access-system
      # TODO: cell.nixosProfiles.hardware.rtw89
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-grub-zfs
      cell.nixosProfiles.filesystems.impermanence.default

      inputs.disko.nixosModules.disko
    ];
}
