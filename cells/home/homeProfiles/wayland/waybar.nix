{ config, osConfig, pkgs, ... }:
let
  # inherit (lib // builtins) toInt toString;
  # inherit (config.home.sessionVariables)
  #   HM_FONT_NAME
  #   HM_FONT_SIZE;
in
# TODO: https://github.com/thiagokokada/nix-configs/blob/master/home-manager/desktop/sway/waybar.nix
{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;
  programs.waybar.systemd.target = "wayland-session@Hyprland.target";

  systemd.user.services.waybar.Unit.After = [ "wayland-wm@Hyprland.service" ];

  programs.waybar.settings.masterBar = {
    position = "top";
    modules-left = [
      "hyprland/workspaces"
      "hyprland/window"
    ];

    # modules-center = [ "hyprland/language" ];

    modules-right = [
      "hyprland/submap"
      "hyprland/language"
      "temperature"
      "battery"
      "tray"
      "pulseaudio"
      "clock"
      "custom/wlogout"
    ];

    "custom/wlogout" = {
      format = "⏻";
      on-click = "${config.programs.wlogout.command}";
      tooltip = false;
    };

    pulseaudio.format = "{volume}% {icon} {format_source}";
    pulseaudio.format-bluetooth = "{volume}% {icon} {format_source}";
    pulseaudio.format-bluetooth-muted = " {icon} {format_source}";
    pulseaudio.format-muted = " {format_source}";
    pulseaudio.format-source = "{volume}% ";
    pulseaudio.format-source-muted = "";
    pulseaudio.format-icons.headphone = "";
    # pulseaudio.format-icons.hands-free = "";
    # pulseaudio.format-icons.headset = "";
    # pulseaudio.format-icons.phone = "";
    # pulseaudio.format-icons.portable = "";
    pulseaudio.format-icons.car = "";
    pulseaudio.format-icons.default = [ "" "" ];
    pulseaudio.on-click = "${pkgs.pavucontrol}/bin/pavucontrol";

    "hyprland/language".format = "󰌌 {short}";
    # "hyprland/language".format-en = "🇬🇧 (English-US)";
    # "hyprland/language".format-YAZHERTY = "🇷🇺 (YAZHERTY)";
    # "hyprland/language".format-ru-phonetic = "🇷🇺 (ru-phonetic)";
    # "hyprland/language".format-ru-phonetic_YAZHERTY = "🇷🇺 (ru-phonetic_YAZHERTY)";
    # "hyprland/language".format-ru-phonetic_yazherty = "🇷🇺 (ru-phonetic_yazherty)";
    # "hyprland/language".format-ru = "🇷🇺 (RU)";
    # "hyprland/language".format-phonetic_YAZHERTY = "🇷🇺 (phonetic_YAZHERTY)";
    # "hyprland/language".format-phonetic_yazherty = "🇷🇺 (phonetic_yazherty)";
    # "hyprland/language".keyboard-name = "at-translated-set-2-keyboard";

    "hyprland/window".format = " {}";
    "hyprland/window".max-length = 100;
    "hyprland/window".icon = true;

    "hyprland/workspaces".format = "{name}";

    "hyprland/submap" = {
      "format" = "{} ✌🏻";
      "max-length" = 30;
      "tooltip" = false;
    };

    tray.spacing = 4;
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
