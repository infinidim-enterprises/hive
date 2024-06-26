{ config, lib, pkgs, ... }:

{
  # TODO: https://github.com/cbr4l0k/.dotfiles/blob/master/config/wlogout/layout
  programs.wlogout.enable = true;
  programs.wlogout.layout = [
    {
      label = "lock";
      action = "hyprlock";
      text = "Lock [l]";
      keybind = "l";
    }
    {
      label = "reboot";
      action = "systemctl reboot";
      text = "Reboot [r]";
      keybind = "r";
    }

    {
      label = "shutdown";
      action = "systemctl poweroff";
      text = "Shutdown [s]";
      keybind = "s";
    }
    # {
    #   label = "hibernate";
    #   action = "systemctl hibernate";
    #   text = "Hibernate";
    #   keybind = "h";
    # }
    {
      label = "logout";
      action = "loginctl terminate-user $USER";
      text = "Logout [o]";
      keybind = "o";
    }
    {
      label = "suspend";
      action = "systemctl suspend";
      text = "Suspend [u]";
      keybind = "u";
    }
  ];
}
