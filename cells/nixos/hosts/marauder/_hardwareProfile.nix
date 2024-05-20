{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  # NOTE: https://askubuntu.com/questions/1418992/sgx-disabled-by-bios-message-on-ubuntu-20-04-booting
  boot.kernelParams = [ "nosgx" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];

  boot.loader.efi.canTouchEfiVariables = false;

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  # disko.rootMountPoint = "/mnt/install";

  imports =
    [
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.core.kernel.physical-access-system

      inputs.disko.nixosModules.disko
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-boot

      # FIXME: error: cannot call 'getFlake' on unlocked flake reference (use --impure to override)
      # cell.nixosModules.bootstrap
      # {
      #   _module.args.self = with builtins; getFlake
      #     (unsafeDiscardStringContext (toString inputs.self));
      # }
    ];
}
