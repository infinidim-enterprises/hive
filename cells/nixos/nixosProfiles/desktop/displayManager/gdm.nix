{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  services.xserver.displayManager.gdm.settings = {
    daemon.IncludeAll = false;
  };

  # services.xserver.displayManager.gdm.debug
  # services.xserver.displayManager.gdm.banner
}
