{ config, lib, pkgs, ... }:

{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = false;
  programs.waybar.settings = {
    position = "top";
    modules-left = [ "hyprland/workspaces" ];
    modules-right = [ "hyprland/language" "tray" "battery" "clock" ];
  };
}
