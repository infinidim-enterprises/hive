{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (builtins) baseNameOf;
in
{
  deploy.params.cpu = "intel";
  deploy.params.gpu = "intel";
  deploy.params.ram = 8;

  home-manager.sharedModules = [
    ({ config, lib, ... }: lib.mkIf config.services.kanshi.enable {
      services.kanshi.settings =
        let
          output_panel = {
            criteria = "eDP-1";
            mode = "1920x1080";
            status = "enable";
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
              (output_panel // { position = "0,1080"; })
            ];
          }
        ];
    })

    ({ config, lib, ... }: lib.mkIf
      (config.wayland.windowManager.hyprland.enable
        && !config.services.kanshi.enable)
      {
        wayland.windowManager.hyprland.settings.monitor = [
          "eDP-1,preferred,auto,1"
        ];
      })
  ];

  # boot.plymouth.enable = true;
  # pkgs.plymouth-matrix-theme

  # hardware.bumblebee.enable = true;
  # hardware.bumblebee.group = "video";
  # hardware.bumblebee.driver = "nvidia";

  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "drm.debug=0" "modeset=1" ];
  boot.extraModprobeConfig = ''
    options i915 verbose_state_checks=0 guc_log_level=0
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  # boot.kernelPatches = [
  #   {
  #     name = "disable showing '*ERROR* GPIO index request failed'";
  #     patch = ./intel_dsi_vbt.patch;
  #   }
  # ];

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  disko.devices = cell.diskoConfigurations.${baseNameOf ./.} { inherit lib; };
  imports =
    [
      inputs.disko.nixosModules.disko

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
