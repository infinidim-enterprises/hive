{ inputs, cell, ... }:

{ pkgs, ... }:

{
  xdg.autostart.enable = true;
  xdg.menus.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.sounds.enable = true;

  # xdg.portal.enable = false;
  # xdg.portal.wlr.enable = false;
  # xdg.portal.configPackages = with pkgs; [
  #   # xdg-desktop-portal
  #   # xdg-desktop-portal-gnome
  #   # xdg-desktop-portal-gtk
  #   xdg-desktop-portal-xapp
  # ];

  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg_utils
    xdg-user-dirs
    xdgmenumaker
  ];
}
