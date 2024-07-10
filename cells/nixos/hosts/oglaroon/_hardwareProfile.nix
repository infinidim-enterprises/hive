{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  deploy.params.cpu = "amd";
  deploy.params.gpu = "amd";
  deploy.params.ram = 64;
  # deploy.params.zfsCacheMax = 8;

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
    ({ config, lib, ... }: lib.mkIf config.programs.waybar.enable
      {
        programs.waybar.settings.masterBar.output = [ "eDP-1" ];
      })

  ];

  services.logind.powerKeyLongPress = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
  boot.initrd.availableKernelModules = [ "nvme" "nvme_core" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "nvme_core.default_ps_max_latency_us=0" # NOTE: possibly a workaround for shitty Crucial nvme drive
  ];

  disko.devices = cell.diskoConfigurations.oglaroon { inherit lib; };
  imports =
    [
      # TODO: cell.nixosProfiles.hardware.rtw89
      # cell.nixosProfiles.boot.systemd-grub-zfs

      inputs.disko.nixosModules.disko

      cell.nixosProfiles.hardware.amd
      cell.nixosProfiles.hardware.opengl
      cell.nixosProfiles.hardware.common
      cell.nixosProfiles.hardware.bluetooth
      cell.nixosProfiles.hardware.tlp
      cell.nixosProfiles.hardware.fwupd
      cell.nixosProfiles.core.kernel.physical-access-system
      cell.nixosProfiles.filesystems.zfs
      cell.nixosProfiles.boot.systemd-boot
      cell.nixosProfiles.filesystems.impermanence.default
    ];
}
