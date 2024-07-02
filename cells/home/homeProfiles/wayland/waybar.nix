{ lib, config, osConfig, ... }:
let
  inherit (lib // builtins) toInt toString;
  inherit (config.home.sessionVariables)
    HM_FONT_NAME
    HM_FONT_SIZE;
in
# TODO: https://github.com/thiagokokada/nix-configs/blob/master/home-manager/desktop/sway/waybar.nix
{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;

  programs.waybar.settings.masterBar = {
    position = "top";
    modules-left = [ "hyprland/workspaces" ];
    # modules-center = [ ];
    modules-right = [
      "hyprland/language"
      "temperature"
      "battery"
      "tray"
      "clock"
      "custom/wlogout"
    ];

    "custom/wlogout" = {
      format = "⏻";
      on-click = "wlogout";
      tooltip = false;
    };

    "hyprland/language".format = "󰌌 {short}";

    "hyprland/window".format = " {}";
    "hyprland/window".max-length = 100;

    "hyprland/workspaces".format = "{name}";

    tray.spacing = 5;
    temperature.format = "{temperatureC}°C ";

    # NOTE: https://github.com/Alexays/Waybar/issues/2982
    clock.format = "{:L%a %b %d, %H:%M}"; # (%Z)
    clock.tooltip = true;
    clock.tooltip-format = "<tt>{calendar}</tt>"; # \n\n{tz_list}
    clock.timezone = osConfig.time.timeZone;

    # clock.timezones = [
    #   # FIXME: clock.timezones
    #   "Etc/UTC"
    #   "Europe/London"
    #   "Europe/Berlin"
    #   "Europe/Moscow"
    #   "Europe/Kiev"
    #   "Asia/Tel_Aviv"
    #   "America/New_York"
    #   "America/Los_Angeles"
    #   "Asia/Tokyo"
    #   "Asia/Hong_Kong"
    #   "Australia/Melbourne"
    # ];

    clock.calendar = {
      mode = "month";
      mode-mon-col = 3;
      weeks-pos = "right";
      on-scroll = 1;
      format.months = "<span color='#fdf6e3'><b>{}</b></span>";
      format.days = "<span color='#657b83'><b>{}</b></span>";
      format.weeks = "<span color='#268bd2'><b>{}</b></span>";
      format.weekdays = "<span color='#b58900'><b>{}</b></span>";
      format.today = "<span color='#cb4b16'><b><u>{}</u></b></span>";
    };

    clock.actions.on-click-right = "mode";
    # clock.actions.on-click-forward = "tz_up";
    # clock.actions.on-click-backward = "tz_down";
    # clock.actions.on-scroll-up = "shift_up";
    # clock.actions.on-scroll-down = "shift_down";

    battery = {
      states.good = 95;
      states.warning = 30;
      states.critical = 15;
      format = "<span weight='bold'>{icon}</span> {capacity}%";
      format-charging = " {capacity}%";
      format-plugged = " {capacity}%";
      format-discharging = "{icon}  {capacity}%";
      format-alt = "{icon} {time}";
      format-icons = [ "" "" "" "" "" ];
    };
  };
}
