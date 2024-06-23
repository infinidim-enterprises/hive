{ lib, osConfig, ... }:

{
  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;
  programs.waybar.style =
    # lib.fileContents ./waybar_solarized-dark.css;
    # NOTE: https://gitlab.gnome.org/GNOME/gtk/-/blob/gtk-3-24/gtk/theme/Adwaita/_colors-public.scss
    ''
      * {
        border: none;
        border-radius: 0;
        font-family:
          UbuntuMono Nerd Font Mono, FontAwesome;
        font-size: 18px;
        min-height: 0;
      }

      window#waybar {
          background: @theme_base_color;
          border-bottom: 1px solid @unfocused_borders;
          color: @theme_text_color;
      }
    '';
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
      mode = "month";
      mode-mon-col = 3;
      weeks-pos = "right";
      on-scroll = 1;
      format.months = "<span color='#657b83'><b>{}</b></span>";
      format.days = "<span color='#657b83'><b>{}</b></span>";
      format.weeks = "<span color='#657b83'><b>W{}</b></span>";
      format.weekdays = "<span color='#657b83'><b>{}</b></span>";
      format.today = "<span color='#657b83'><b><u>{}</u></b></span>";
    };

    clock.actions.on-click-right = "mode";
    clock.actions.on-click-forward = "tz_up";
    clock.actions.on-click-backward = "tz_down";
    clock.actions.on-scroll-up = "shift_up";
    clock.actions.on-scroll-down = "shift_down";
  };
}
