{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{
  deploy.params.cpu = "intel";
  deploy.params.gpu = "intel";
  deploy.params.ram = 8;

  # boot.plymouth.enable = true;
  # NOTE: i915 *ERROR* GPIO index request failed (-ENOENT)
  boot.kernelParams = [ "drm.debug=0" ];
  # NOTE: tradeoff - get lower wifi speeds, but at least no interruptions
  # NOTE: iwlmvm doesn't allow to disable BT Coex, check bt_coex_active module parameter
  # bt_coex_active=0
  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=1
    options i915 verbose_state_checks=0 guc_log_level=0
  '';

  boot.consoleLogLevel = 0;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  boot.kernelPatches = [
    {
      name = "iotop CONFIG_TASK_DELAY_ACCT";
      patch = null;
      extraConfig = ''
        TASK_DELAY_ACCT y
        TASKSTATS y
      '';
    }
    {
      name = "disable showing '*ERROR* GPIO index request failed'";
      patch = ./intel_dsi_vbt.patch;
    }
  ];

  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.initrd.kernelModules = [ "drm" "intel_agp" "i915" ];
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "intel" ];

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  hardware.bluetooth.disabledPlugins = [
    "bap"
    "bass"
    "mcp"
    "vcp"
    "micp"
    "ccp"
    "csip"
  ];

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
      cell.nixosProfiles.hardware.bluetooth
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
