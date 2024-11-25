{ inputs, cell, ... }:

{ pkgs, ... }:

{
  xdg.autostart.enable = true;
  xdg.menus.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.sounds.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-launch
    xdgmenumaker
    xdg-user-dirs
    xdg-dbus-proxy
    xdg-terminal-exec
  ];
}
