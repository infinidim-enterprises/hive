{ inputs, cell, ... }:

{ pkgs, ... }:

{
  xdg.autostart.enable = true;
  xdg.menus.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.sounds.enable = true;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.configPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-xapp
  ];

  environment.systemPackages = with pkgs; [ xdg-utils ];
}
