{ config, lib, pkgs, ... }:

{
  # TODO: https://github.com/cbr4l0k/.dotfiles/blob/master/config/wlogout/layout
  programs.wlogout.enable = true;
  programs.wlogout.layout = [
    {
      label = "lock";
      action = "hyprlock";
      text = "Lock";
      keybind = "l";
    }
    {
      label = "reboot";
      action = "systemctl reboot";
      text = "Reboot";
      keybind = "r";
    }

    {
      label = "shutdown";
      action = "systemctl poweroff";
      text = "Shutdown";
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
      text = "Logout";
      keybind = "e";
    }
    {
      label = "suspend";
      action = "systemctl suspend";
      text = "Suspend";
      keybind = "u";
    }
  ];
}
