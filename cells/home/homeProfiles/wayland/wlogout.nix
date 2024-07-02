{ config, lib, pkgs, ... }:
let
  logout_script = pkgs.writeScript "wl_logout" ''
    hyprctl dispatch exit 0
    systemctl --user stop hyprland-session.target
    systemctl --user stop nixos-fake-graphical-session.target
    systemctl --user stop graphical-session-pre.target
    systemctl --user stop graphical-session.target
  '';
in
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
      # action = "hyprctl dispatch exit 0";
      # action = "loginctl terminate-session self";
      action = logout_script;
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
