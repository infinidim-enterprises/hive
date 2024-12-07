{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{

  # disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };

  imports =
    [
      # inputs.disko.nixosModules.disko
      inputs.raspberry-pi-nix.nixosModules.raspberry-pi
      inputs.raspberry-pi-nix.nixosModules.sd-image

      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.core.kernel.physical-access-system
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
