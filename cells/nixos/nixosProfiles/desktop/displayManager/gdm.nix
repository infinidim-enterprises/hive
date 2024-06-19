{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  services.xserver.displayManager.gdm.settings = {
    daemon.IncludeAll = false;
  };

  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };
  }];

  # services.xserver.displayManager.gdm.debug
  # services.xserver.displayManager.gdm.banner
}
