{ inputs, cell, ... }:

{ config, lib, pkgs, modulesPath, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  # deploy.params.cpu = "amd";
  # deploy.params.gpu = "amd";
  # deploy.params.ram = 64;

  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];

  # ExecStartPre = "${config.systemd.package}/bin/udevadm trigger -s usb -a idVendor=${apple}";
  # RUN+="/path/to/your/program"
  # boot.initrd.services.udev.rules = ''
  #   ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="6080", ATTRS{idProduct}=="8061", OPTIONS="log_level=debug"
  # '';

  /*
    systemd.paths.trackpoint = {
    pathConfig = {
      PathExists = "/sys/devices/rmi4-00/rmi4-00.fn03/serio2";
      Unit = "trackpoint.service";
    };
    };

    systemd.services.trackpoint.script = ''
    ${config.systemd.package}/bin/udevadm trigger --attr-match=name="${config.hardware.trackpoint.device}"
    '';
  */

  # # /etc/udev/rules.d/99-usb.rules
  #

  # ##
  # Bus 001 Device 002: ID 6080:8061 AMR-4630-XXX-0- 0-1023 USB KEYBOARD
  # ##
  # boot.initrd.systemd.package
  # boot.initrd.services.udev.packages
  #

  security.tpm2.enable = true;
  # security.tpm2.abrmd.enable = true;
  environment.systemPackages = with pkgs; [
    tpm2-abrmd
    tpm2-tools
    tpm2-openssl
    tpm2-pkcs11
    tpm2-totp
    tpm2-tss
    # tpmmanager
  ];

  # boot.initrd.systemd.managerEnvironment.SYSTEMD_LOG_LEVEL = "debug";

  # boot.kernelParams = [
  #   # "udev.log_level=debug"

  #   # "i8042.nopnp"
  #   "i8042.debug"
  #   "i8042.kbdreset"
  # ];

  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  # boot.growPartition = lib.mkDefault true;
  # boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = lib.mkIf config.boot.loader.grub.enable (lib.mkDefault "nodev");
  # if (pkgs.stdenv.system == "x86_64-linux") then
  #   (lib.mkDefault "/dev/vda")
  # else
  #   (lib.mkDefault "nodev");

  imports =
    [
      inputs.nixos-hardware.nixosModules.gpd-micropc

      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
    ];
}
