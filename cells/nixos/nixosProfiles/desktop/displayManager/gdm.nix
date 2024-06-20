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

  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  environment.systemPackages = [
    inputs.cells.common.packages.solarized-dark-gnome-shell
  ];

  programs.dconf.profiles.gdm.databases = [{
    settings = {
      # "org/gnome/settings-daemon/plugins/power" = {
      #   sleep-inactive-ac-type = "nothing";
      #   sleep-inactive-battery-type = "nothing";
      # };

      "org/gnome/desktop/interface".font-name = "UbuntuMono Nerd Font Mono 20";

      "org/gnome/login-screen".disable-user-list = true;
      # "org/gnome/login-screen".logo = "";

      "org/gnome/desktop/peripherals/mouse".accel-profile = "adaptive";
      "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;

      "org/gnome/desktop/background".primary-color = "#002b36";

      # "org/gnome/desktop/interface" = {
      #   cursor-theme = config.stylix.cursor.name;
      #   cursor-size = lib.gvariant.mkInt32 config.stylix.cursor.size;
      # };


      # "org/gnome/desktop/interface".gtk-theme = "Dracula";
    };
  }];
}
