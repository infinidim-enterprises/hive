{ config, lib, pkgs, ... }:

{
  services.xsettingsd.enable = true;
  # services.xsettingsd.settings = {};

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  wayland.windowManager.hyprland.systemd.enableXdgAutostart = true;
  wayland.windowManager.hyprland.settings = {

    monitor = [ ",preferred,auto,1,transform,3" ];

    exec-once = [
      "systemctl --user start nixos-fake-graphical-session.target"
      "$terminal"
      "nm-applet &"
      # "waybar"
    ];

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    general = {
      gaps_in = 1;
      gaps_out = 1;
      border_size = 1;

      "col.active_border" = "rgba(839496FF)";
      "col.inactive_border" = "rgba(002b36ff)";

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
      # shadow_range = 4;
      # shadow_render_power = 3;
      # "col.shadow" = "rgba(1a1a1aee)";

      blur.enabled = false;
      # blur.size = 3;
      # blur.passes = 1;
      # blur.vibrancy = 0.1696;

    };

    animations.enabled = false;
    animations.first_launch_animation = false;
    # animations.bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
    # animations.animation = [
    #   "windows, 1, 7, myBezier"
    #   "windowsOut, 1, 7, default, popin 80%"
    #   "border, 1, 10, default"
    #   "borderangle, 1, 8, default"
    #   "fade, 1, 7, default"
    #   "workspaces, 1, 6, default"
    # ];

    dwindle.pseudotile = true;
    dwindle.preserve_split = true; # You probably want this

    misc.force_default_wallpaper = 0;
    misc.disable_hyprland_logo = true;
    misc.disable_splash_rendering = true;
    misc.font_family = "UbuntuMono Nerd Font Mono";
    misc.background_color = "0x002b36";

    cursor.hide_on_key_press = true;

    input = {
      kb_layout = "us, ru";
      kb_variant = ",phonetic_YAZHERTY";
      kb_options = "grp:shifts_toggle";

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      accel_profile = "adaptive";
      touchpad = {
        natural_scroll = false;
      };
    };

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures.workspace_swipe = false;


    # TODO: $fileManager = dolphin
    "$mainMod" = "SUPER";
    "$terminal" = "tilix";
    "$menu" = "wofi --show drun";

    bind = [
      # "$mainMod, C, killactive,"
      "$mainMod, M, exec, hyprctl dispatch togglemax"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating,"
      # "$mainMod, R, exec, $menu"
      "$mainMod, P, pseudo,"
      "$mainMod, J, togglesplit,"

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

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
    bind = Control_L, apostrophe, submap, wofi_menu
    submap = wofi_menu
    bind = Control_L,period,exec,$menu
    bind = Control_L,period,submap,reset
    bind = ,k,killactive,
    bind = ,k,submap,reset
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
