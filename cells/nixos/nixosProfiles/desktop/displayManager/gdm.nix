{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  services.xserver.displayManager.gdm.settings = {
    daemon.IncludeAll = false;
  };

  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

  programs.dconf.profiles.gdm.databases = [{
    settings = {
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };
      "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
      "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;
    };
  }];

  # services.xserver.displayManager.gdm.debug
  # services.xserver.displayManager.gdm.banner
}
