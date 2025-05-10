{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkAfter
    mkIf
    mkDefault
    mkMerge;
in
mkMerge
  [
    {
      boot.kernelParams = mkAfter [
        "consoleblank=90"
        "systemd.gpt_auto=0"
        "systemd.crash_reboot=1"
        "systemd.dump_core=0"
      ];

      boot.initrd.compressor = mkDefault "${pkgs.pigz}/bin/pigz --best --recursive";
      powerManagement.resumeCommands = mkIf config.services.zerotierone.enable ''
        ${pkgs.systemd}/bin/systemctl --no-block restart zerotierone.service
      '';

    }

    # (mkIf config.deploy.publicHost.enable {})

    (mkIf (!config.deploy.publicHost.enable) {
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd.services.systemd-udev-settle.enable = false;
      systemd.services.NetworkManager-wait-online.enable = false;

      # systemd.enableUnifiedCgroupHierarchy = true;
      systemd.tmpfiles.rules = mkAfter [ "d /mnt 0755 root root - -" ];
      systemd.extraConfig = ''
        DefaultTimeoutStopSec=15s
      '';

      systemd.coredump.enable = true;
      systemd.coredump.extraConfig = ''
        ProcessSizeMax=32G
        ExternalSizeMax=32G
        JournalSizeMax=64M
      '';

      environment.systemPackages = [ pkgs.efibootmgr ];
      powerManagement.cpuFreqGovernor = mkDefault "powersave";

      # TODO: services.smartd.enable

      boot.kernelPackages = mkDefault pkgs.linuxPackages;

      boot.loader.timeout = mkDefault 0;
      boot.supportedFilesystems = [ "ext4" "zfs" "nfs4" "nfs" ];
      boot.initrd.supportedFilesystems = [ "ext4" "vfat" ];

      # boot.initrd.kernelModules = [ "nfs" ];

      boot.initrd.availableKernelModules = [
        #"battery" # NOTE: on microPC the builtin keyboard needs this!
        # "hid_generic"
        # Mostly useful
        "crc32c_generic"
        "xhci_pci"
        "ehci_pci"
        "sdhci_pci"
        # "sdhci_acpi"
        "ahci"
        "uhci_hcd"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "rtsx_pci_sdmmc"
        "rtsx_usb_sdmmc"
      ];

      hardware.firmware = [ pkgs.firmwareLinuxNonfree ];

      boot.kernelParams = [
        # NOTE: https://askubuntu.com/questions/1418992/sgx-disabled-by-bios-message-on-ubuntu-20-04-booting
        "nosgx"
        "panic=10"
        "boot.panic_on_fail"
        "udev.log_level=err"
        # "quiet"
      ];
    })

    (mkIf (!config.deploy.publicHost.enable) {
      boot.kernelParams = mkAfter [ "quiet" ];
    })
  ]
