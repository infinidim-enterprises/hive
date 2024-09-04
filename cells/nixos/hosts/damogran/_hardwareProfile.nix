{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{
  # deploy.params.cpu = "intel";
  # deploy.params.gpu = "intel";

  # boot.consoleLogLevel = 0;
  # boot.kernelParams = [ "drm.debug=0" "modeset=1" ];
  # boot.extraModprobeConfig = ''
  #   options i915 verbose_state_checks=0 guc_log_level=0
  # '';
  # boot.blacklistedKernelModules = [ "nouveau" ];
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;

  # disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };

  imports =
    [
      inputs.raspberry-pi-nix.nixosModules.raspberry-pi

      # inputs.disko.nixosModules.disko

      # cell.nixosProfiles.hardware.opengl
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.core.kernel.physical-access-system
      # cell.nixosProfiles.filesystems.zfs
      # cell.nixosProfiles.boot.systemd-boot
      # cell.nixosProfiles.filesystems.impermanence.default
    ];

  raspberry-pi-nix.board = "bcm2711";

  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.i2c-tools ];

  hardware.raspberry-pi.config.all = {
    base-dt-params.BOOT_UART.value = 1;
    base-dt-params.BOOT_UART.enable = true;

    base-dt-params.uart_2ndstage.value = 1;
    base-dt-params.uart_2ndstage.enable = true;

    dt-overlays.disable-bt.enable = true;
    dt-overlays.disable-bt.params = { };
  };

}
