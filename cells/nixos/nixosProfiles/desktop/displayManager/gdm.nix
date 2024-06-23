{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{

  # services.xserver.displayManager.gdm.debug
  # services.xserver.displayManager.gdm.banner

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.displayManager.gdm.settings = {
    daemon.IncludeAll = false;
  };

  services.hardware.bolt.enable = true;

  services.gnome.gnome-settings-daemon.enable = true;
  services.gnome.glib-networking.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.cells.common.packages.solarized-dark-gnome-shell
    inputs.cells.common.packages.solarized-material

    themechanger

    numix-cursor-theme
    gnome.gnome-shell # HACK: gdm-wayland-session: No schemas installed
    gsettings-desktop-schemas
  ];

  programs.dconf.profiles.gdm.databases = [{
    settings = {
      "org/gnome/desktop/interface".font-name = "UbuntuMono Nerd Font Mono 20";

      "org/gnome/login-screen".disable-user-list = true;
      # "org/gnome/login-screen".logo = "";

      "org/gnome/desktop/peripherals/mouse".accel-profile = "adaptive";
      "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;

      "org/gnome/desktop/background".primary-color = "#002b36";

      # "org/gnome/desktop/interface".gtk-theme = "Solarized-Dark-Green-GS-3.36";
      "org/gnome/desktop/interface".gtk-theme = "Material-Solarized";
      "org/gnome/desktop/interface".cursor-theme = "Numix-Cursor-Light";
      "org/gnome/desktop/interface".cursor-size = lib.gvariant.mkInt32 32;
    };
  }];
}
