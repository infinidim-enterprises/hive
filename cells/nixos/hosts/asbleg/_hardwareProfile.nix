{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{
  deploy.params.cpu = "intel";
  deploy.params.gpu = "intel";
  deploy.params.ram = 8;

  boot.consoleLogLevel = 0;
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.initrd.kernelModules = [ "drm" "intel_agp" "i915" ];
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "intel" ];

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  imports =
    [ inputs.disko.nixosModules.disko ] ++
    [
      inputs.nixos-hardware.nixosModules.gpd-micropc
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.hardware.intel
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
      # cell.nixosProfiles.boot.systemd-grub-zfs-luks-gpg
      cell.nixosProfiles.boot.systemd-boot
      cell.nixosProfiles.filesystems.impermanence.default
    ];
}
