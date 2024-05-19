{ inputs, cell, ... }:

{ lib, ... }:
let inherit (lib) mkDefault; in
{
  boot.initrd.systemd.enable = mkDefault true;
  # initrd.systemd.emergencyAccess = mkDefault true;

  boot.loader.timeout = mkDefault 0;
  boot.loader.efi.canTouchEfiVariables = mkDefault true;
  boot.loader.grub = {
    # NOTE: https://discourse.nixos.org/t/configure-grub-on-efi-system/2926/7
    enable = mkDefault true;
    efiSupport = true;
    device = mkDefault "nodev";
  };
}
