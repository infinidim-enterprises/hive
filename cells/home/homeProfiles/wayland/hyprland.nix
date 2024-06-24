{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins) isInt toString;
  cursorsize =
    if config.gtk.enable && (isInt config.gtk.cursorTheme.size)
    then toString config.gtk.cursorTheme.size
    else "24";
in
{
  # TODO: https://github.com/sentriz/cliphist

  services.wlsunset.enable = true;
  services.wlsunset.temperature.day = 4200;
  services.wlsunset.temperature.night = 3600;
  services.wlsunset.sunrise = "07:30";
  services.wlsunset.sunset = "19:30";

  services.xsettingsd.enable = true;
  # services.xsettingsd.settings = {};

  services.hypridle.enable = true;
  services.hypridle.settings = {
    general = {
      before_sleep_cmd = "loginctl lock-session";
      after_sleep_cmd = "hyprctl dispatch dpms on";
      lock_cmd = "pidof hyprlock || hyprlock";
      ignore_dbus_inhibit = false;
    };

    listener = [
      {
        timeout = 900; # 15 min
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 1800; # 20 min
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };

  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      ignore_empty_input = true;
      disable_loading_bar = true;
      grace = 0;
      hide_cursor = true;
      no_fade_in = false;
    };

    background = [
      {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }
    ];

    input-field = [
      {
        size = "200, 50";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(131, 148, 150)";
        inner_color = "rgb(0, 43, 54)";
        outer_color = "rgb(131, 148, 150)";
        outline_thickness = 5;
        hide_input = false;
        placeholder_text = "Password...";
        shadow_passes = 2;
      }
    ];
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  wayland.windowManager.hyprland.systemd.enableXdgAutostart = true;
  wayland.windowManager.hyprland.settings = {

    exec-once = [
      "systemctl --user start nixos-fake-graphical-session.target"
      "$terminal"
      "nm-applet &"
    ];

    env = [
      "XCURSOR_SIZE,${cursorsize}"
      "HYPRCURSOR_SIZE,${cursorsize}"
    ];

    general = {
      gaps_in = 1;
      gaps_out = 1;
      border_size = 1;
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 0;

      # Change transparency of focused and unfocused windows
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      drop_shadow = false;
      blur.enabled = false;
    };

    animations.enabled = false;
    animations.first_launch_animation = false;

    dwindle.pseudotile = true;
    dwindle.preserve_split = true; # You probably want this

    misc.force_default_wallpaper = 0;
    misc.disable_hyprland_logo = true;
    misc.disable_splash_rendering = true;
    misc.font_family = "UbuntuMono Nerd Font Mono";
    misc.background_color = "0x002b36";

    cursor.hide_on_key_press = true;

    input.kb_layout = "us, ru";
    input.kb_variant = ",phonetic_YAZHERTY";
    input.kb_options = "grp:shifts_toggle";

    input.follow_mouse = 1;

    input.sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    input.accel_profile = "adaptive";
    input.touchpad.natural_scroll = true;

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures.workspace_swipe = false;

    # TODO: $fileManager = dolphin
    "$mainMod" = "SUPER";
    "$terminal" = "tilix";
    "$menu" = "wofi --show drun";

    bind = [
      "$mainMod, Return, fullscreen, 0"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating,"
      "$mainMod, P, pseudo,"
      "$mainMod, J, togglesplit,"

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Move the window itself
      "$mainMod Alt_L, Left, movewindow, l"
      "$mainMod Alt_L, Right, movewindow, r"
      "$mainMod Alt_L, Up, movewindow, u"
      "$mainMod Alt_L, Down, movewindow, d"

      "Alt_L, Tab, cyclenext"
      "$mainMod, Tab, focuscurrentorlast"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Example special workspace (scratchpad)
      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
    ];

    bindm = [
      # mouse movements
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      # "$mainMod ALT, mouse:272, resizewindow"
    ];

    binds = [
      "Control_L&Alt_L, Delete, exec, wlogout"

      "Control_L&Alt_L, Right, workspace, +1"
      "Control_L&Alt_L, Left, workspace, -1"

      "Control_L&Shift_L, Q, exit"
      "Control_L&Shift_L, Return, exec, $terminal"
    ];

    windowrulev2 = [
      "suppressevent maximize, class:.*"
    ];
  };

  # (set-prefix-key (kbd "C-'"))
  # (kbd "C-.") "$mainMod, C, killactive,"
  wayland.windowManager.hyprland.extraConfig = ''
    bind = Control_L, apostrophe, submap, keychords
    submap = keychords
    bind = Control_L,period,exec,$menu
    bind = Control_L,period,submap,reset
    bind = ,k,killactive,
    bind = ,k,submap,reset
    bind = ,e,exec,emacsclient -c
    bind = ,e,submap,reset
    submap = reset
  '';
}
/*

  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: The XKEYBOARD keymap compiler (xkbcomp) reports:
  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: > Warning:          Unsupported maximum keycode 708, clipping.
  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: >                   X11 cannot support keycodes above 255.
  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: > Warning:          Could not resolve keysym XF86KbdInputAssistPrevgrou
  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: > Warning:          Could not resolve keysym XF86KbdInputAssistNextgrou
  Jun 20 23:15:16 asbleg org.gnome.Shell.desktop[17393]: Errors from xkbcomp are not fatal to the X server
  Jun 20 2

*/
