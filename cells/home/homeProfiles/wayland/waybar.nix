{ config, lib, pkgs, ... }:

{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = false;
  programs.waybar.settings.masterBar = {
    position = "top";
    modules-left = [ "hyprland/workspaces" ];
    modules-right = [ "hyprland/language" "tray" "battery" "clock" ];

    # "hyprland/workspaces" = { };

    clock.format = "{:%a %b %d, %H:%M}";
  };
}
