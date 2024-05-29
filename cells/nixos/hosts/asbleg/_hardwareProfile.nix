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
  boot.kernelPackages = pkgs.linuxPackages; #_xanmod_stable;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.initrd.kernelModules = [ "drm" "intel_agp" "i915" ];
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "intel" ];

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  # loaded firmware version 29.4063824552.0 7265D-29.ucode
  #
  # NOTE: https://github.com/systemd/systemd/issues/25269
  # services.logind.lidSwitch = "suspend-then-hibernate";
  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=300s
  # '';

  # TODO: maybe? kernelParams = [ "i915.force_probe=!9a49" "xe.force_probe=9a49" ]

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
