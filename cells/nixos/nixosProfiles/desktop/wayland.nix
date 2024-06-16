{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  # programs.hyprland.package
  # programs.hyprland.portalPackage

  programs.hyprland.enable = true;
  programs.hyprland.systemd.setPath.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;

  programs.xwayland.enable = true;
}
