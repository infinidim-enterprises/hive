{ lib, osConfig, ... }:

{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;
  programs.waybar.style = lib.fileContents ./waybar_solarized-dark.css;
  programs.waybar.settings.masterBar = {
    position = "top";
    modules-left = [ "hyprland/workspaces" ];
    modules-right = [ "hyprland/language" "tray" "battery" "clock" ];

    # "hyprland/workspaces" = { };

    clock.format = "{:%a %b %d, %H:%M (%Z)}";
    clock.tooltip = true;
    clock.tooltip-format = "<tt><small>{calendar}</small></tt>"; # {tz_list}
    clock.timezones = [
      # FIXME: clock.timezones
      "Etc/UTC"
      "Europe/London"
      "Europe/Berlin"
      "Europe/Moscow"
      "Europe/Kiev"
      "Asia/Tel_Aviv"
      "America/New_York"
      "America/Los_Angeles"
      "Asia/Tokyo"
      "Asia/Hong_Kong"
      "Australia/Melbourne"
    ];

    clock.calendar = {
      mode = "year";
      mode-mon-col = 3;
      weeks-pos = "right";
      on-scroll = 1;
      format.months = "<span color='#ffead3'><b>{}</b></span>";
      format.days = "<span color='#ecc6d9'><b>{}</b></span>";
      format.weeks = "<span color='#99ffdd'><b>W{}</b></span>";
      format.weekdays = "<span color='#ffcc66'><b>{}</b></span>";
      format.today = "<span color='#ff6699'><b><u>{}</u></b></span>";
    };

    clock.actions.on-click-right = "mode";
    clock.actions.on-click-forward = "tz_up";
    clock.actions.on-click-backward = "tz_down";
    clock.actions.on-scroll-up = "shift_up";
    clock.actions.on-scroll-down = "shift_down";
  };
}
