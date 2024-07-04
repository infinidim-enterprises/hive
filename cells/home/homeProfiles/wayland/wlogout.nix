{ config, osConfig, lib, pkgs, ... }:
let
  logout_script = pkgs.writeScript "wl_logout" ''
    hyprctl dispatch exit 0
    systemctl --user stop hyprland-session.target
    systemctl --user stop nixos-fake-graphical-session.target
    systemctl --user stop graphical-session-pre.target
    systemctl --user stop graphical-session.target
  '';
  cfg = config.programs.wlogout;
  inherit (lib // builtins)
    mkIf
    elem
    head
    last
    toInt
    length
    filter
    hasAttr
    toString
    mkOption
    splitString
    getAttrFromPath;
in
{
  options.programs.wlogout.command =
    let
      part = { total, rate ? 42, base ? 100 }: (rate * total) / base;
      height = outputAttrs:
        if hasAttr "transform" outputAttrs && elem outputAttrs.transform [ "90" "270" ]
        then toInt (head (splitString "x" outputAttrs.mode))
        else toInt (last (splitString "x" outputAttrs.mode));
      primary_output =
        if (length config.services.kanshi.settings) > 0
        then
          head
            (getAttrFromPath [ "profile" "outputs" ]
              (head (filter (e: (length e.profile.outputs) == 1)
                config.services.kanshi.settings)))
        else null;
      margin =
        if primary_output != null
        then part { total = height primary_output; }
        # 42% default margin, assuming 1080 height without output config
        else part { total = 1080; };
    in
    mkOption {
      type = lib.types.str;
      default = "${cfg.package}/bin/wlogout --buttons-per-row "
        + (toString (length cfg.layout))
        + " --margin ${toString margin}"
        + " --primary-monitor 0"
        + " --no-span";
    };

  config = {
    programs.wlogout.enable = true;
    programs.wlogout.layout = [
      {
        label = "lock";
        action = "hyprlock";
        # text = "[l]ock";
        keybind = "l";
      }
      {
        label = "logout";
        # action = "hyprctl dispatch exit 0";
        # action = "loginctl terminate-session self";
        action = logout_script;
        # text = "l[o]gout";
        keybind = "o";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        # text = "s[u]spend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        # text = "[r]eboot";
        keybind = "r";
      }

      {
        label = "shutdown";
        action = "systemctl poweroff";
        # text = "[s]hutdown";
        keybind = "s";
      }
      (mkIf (!elem "nohibernate" osConfig.boot.kernelParams) {
        label = "hibernate";
        action = "systemctl hibernate";
        # text = "[h]ibernate";
        keybind = "h";
      })
    ];
  };
}
