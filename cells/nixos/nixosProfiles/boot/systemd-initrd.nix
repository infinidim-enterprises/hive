{ inputs, cell, ... }:

{ lib, ... }:
{
  boot = {
    loader = {
      # timeout = 0;
      efi.canTouchEfiVariables = lib.mkDefault true;
      # https://discourse.nixos.org/t/configure-grub-on-efi-system/2926/7
      grub = {
        enable = lib.mkDefault true;
        efiSupport = true;
        device = "nodev";
      };
    };
    initrd = {
      systemd = {
        enable = true;
        # emergencyAccess = true;
      };
    };
  };
}
