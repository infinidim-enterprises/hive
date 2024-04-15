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
  boot.loader.grub.extraEntries = ''
    menuentry "Reboot" {
      reboot
    }

    menuentry "Poweroff" {
      halt
    }
  '';

  boot.initrd.luks.gpgSupport = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/086251b4-7d51-4873-b4f6-0aa3ae7088ce";
      preLVM = true;
      allowDiscards = true;
      gpgCard = {
        gracePeriod = 25;
        encryptedPass = "${/etc/nixos/boot/pass/pass.gpg}";
        publicKey = "${/etc/nixos/boot/pub/mog.asc}";
      };
    };
  };
}
