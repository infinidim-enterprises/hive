{ inputs, cell, ... }:

{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  boot.loader.timeout = mkDefault 0;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.enable = mkDefault true;
  boot.loader.grub.splashImage = null;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  # boot.loader.grub.version = 2;
  boot.loader.grub.extraEntries = ''
    menuentry "Reboot" {
      reboot
    }
    menuentry "Poweroff" {
      halt
    }
  '';
}
