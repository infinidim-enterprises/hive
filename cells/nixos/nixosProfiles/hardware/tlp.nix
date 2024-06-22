{ inputs, cell, ... }:

{ pkgs, lib, ... }:

{
  services.tlp = {
    enable = lib.mkDefault (!pkgs.stdenv.isAarch64);
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
      CPU_SCALING_GOVERNOR_ON_BAT = "conservative";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      DISK_IOSCHED = [ "none" ];

      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0 = 80;

      USB_AUTOSUSPEND = 0;

      # USB_DENYLIST = "05a7:4040";

      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_WWAN = 1;

      # RUNTIME_PM_DRIVER_DENYLIST = "nvidia";

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "N";
    };
  };
}
