{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  home-manager.backupFileExtension = "bkp";
  # NOTE: https://askubuntu.com/questions/1418992/sgx-disabled-by-bios-message-on-ubuntu-20-04-booting
  boot.kernelParams = [ "nosgx" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];

  boot.loader.efi.canTouchEfiVariables = false;

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  # disko.rootMountPoint = "/mnt/install";

  services.zfs.autoScrub.enable = lib.mkForce false;

  imports =
    [
      inputs.disko.nixosModules.disko

      cell.nixosProfiles.hardware.intel
      cell.nixosProfiles.hardware.amd
      cell.nixosProfiles.hardware.opengl
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-boot

      # ISSUE: error: cannot call 'getFlake' on unlocked flake reference (use --impure to override)
      # cell.nixosModules.bootstrap
      # {
      #   _module.args.self = with builtins; getFlake
      #     (unsafeDiscardStringContext (toString inputs.self));
      # }
    ];
}
