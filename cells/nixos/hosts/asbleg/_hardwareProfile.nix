{ inputs, cell, ... }:

{ lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{
  deploy.params.cpu = "intel";
  deploy.params.gpu = "intel";
  deploy.params.ram = 8;
  deploy.params.zfsCacheMax = 4;

  home-manager.sharedModules = [
    ({ config, lib, ... }: lib.mkIf config.services.kanshi.enable {
      services.kanshi.settings =
        let
          output_panel = {
            criteria = "DSI-1";
            mode = "720x1280";
            status = "enable";
            transform = "270";
            scale = 1.0;
          };
          output_HDMI-A-1 = {
            criteria = "HDMI-A-1";
            mode = "1920x1080";
            status = "enable";
            scale = 1.0;
          };
        in
        [
          {
            profile.name = "builtin_panel";
            profile.outputs = [ (output_panel // { position = "0,0"; }) ];
          }

          {
            profile.name = "panel_and_hdmi";
            profile.outputs = [
              (output_HDMI-A-1 // { position = "0,0"; })
              (output_panel // { position = "320,1080"; })
            ];
          }
        ];
    })

    ({ config, lib, ... }: lib.mkIf
      (config.wayland.windowManager.hyprland.enable
        && !config.services.kanshi.enable)
      {
        wayland.windowManager.hyprland.settings.monitor = [
          "DSI-1,preferred,auto,1,transform,3"
        ];
      })
  ];

  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "drm.debug=0" ];
  # NOTE: tradeoff - get lower wifi speeds, but at least no interruptions
  # NOTE: iwlmvm doesn't allow to disable BT Coex, check bt_coex_active module parameter
  # bt_coex_active=0
  # options iwlwifi 11n_disable=1
  boot.extraModprobeConfig = ''
    options i915 verbose_state_checks=0 guc_log_level=0
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelPatches = [
    {
      # NOTE: annoying messages removed on gpd micro-pc
      # i915 *ERROR* GPIO index request failed (-ENOENT)
      name = "disable showing '*ERROR* GPIO index request failed'";
      patch = ./intel_dsi_vbt.patch;
    }
  ];

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  # NOTE: https://github.com/systemd/systemd/issues/25269
  # services.logind.lidSwitch = "suspend-then-hibernate";
  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=300s
  # '';

  # TODO: maybe? kernelParams = [ "i915.force_probe=!9a49" "xe.force_probe=9a49" ]

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.nixos-hardware.nixosModules.gpd-micropc

      cell.nixosProfiles.hardware.opengl
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.hardware.intel
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-boot
      cell.nixosProfiles.filesystems.impermanence.default
    ];
}
