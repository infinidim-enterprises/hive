{ config, lib, pkgs, ... }:
let
  logout_script = pkgs.writeScript "wl_logout" ''
    hyprctl dispatch exit 0
    systemctl --user stop hyprland-session.target
    systemctl --user stop nixos-fake-graphical-session.target
    systemctl --user stop graphical-session-pre.target
    systemctl --user stop graphical-session.target
  '';
  cfg = config.programs.wlogout;
in
{
  options.programs.wlogout.command =
    with lib.types;
    with (lib // builtins);
    lib.options.mkOption {
      type = str;
      default = "${cfg.package}/bin/wlogout --buttons-per-row ${toString (length cfg.layout)} --margin 450 --primary-monitor 0";
    };

  config =
    {
      /*
        buttonsPerRow=$(cat ~/.config/wlogout/layout | jq length | wc -l)

        wlogout --buttons-per-row $buttonsPerRow
      */
      programs.wlogout.enable = true;
      programs.wlogout.layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "[l]ock";
          keybind = "l";
        }
        {
          label = "logout";
          # action = "hyprctl dispatch exit 0";
          # action = "loginctl terminate-session self";
          action = logout_script;
          text = "l[o]gout";
          keybind = "o";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "s[u]spend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "[r]eboot";
          keybind = "r";
        }

        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "[s]hutdown";
          keybind = "s";
        }
        # {
        #   label = "hibernate";
        #   action = "systemctl hibernate";
        #   text = "Hibernate";
        #   keybind = "h";
        # }
      ];
    };
}
