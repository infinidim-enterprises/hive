{ osConfig, config, lib, pkgs, ... }:
let
  inherit (lib // builtins) isInt toString;
  cursorsize =
    if config.gtk.enable && (isInt config.gtk.cursorTheme.size)
    then toString config.gtk.cursorTheme.size
    else "24";
in
{
  services.network-manager-applet.enable = osConfig.networking.networkmanager.enable;
  # TODO: investigate mate-wayland-session with hyprland

  # NOTE: kinda need a filemanager
  home.packages = with pkgs; [ mate.caja-with-extensions ];

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "caja-folder-handler.desktop";
    "application/x-mate-saved-search" = "caja-folder-handler.desktop";
  };

  dconf.settings = {
    # NOTE: https://github.com/mate-desktop/caja/blob/1.28/libcaja-private/org.mate.caja.gschema.xml
    "org/mate/caja/preferences".enable-delete = true;
    "org/mate/caja/preferences".confirm-trash = false;
    "org/mate/caja/preferences".default-folder-viewer = "list-view";
    "org/mate/caja/preferences".ctrl-tab-switch-tabs = true;
  };

  # TODO: https://github.com/sentriz/cliphist

  services.wlsunset.enable = true;
  services.wlsunset.temperature.day = 4200;
  services.wlsunset.temperature.night = 3600;
  services.wlsunset.sunrise = "07:30";
  services.wlsunset.sunset = "19:30";

  services.xsettingsd.enable = true;
  services.xsettingsd.settings = {
    /*
      Gdk/UnscaledDPI 98433
      Gdk/WindowScalingFactor 1
      Gtk/AutoMnemonics 1
      Gtk/ButtonImages 1
      Gtk/ColorScheme ""
      Gtk/CursorThemeName "Numix-Cursor-Light"
      Gtk/CursorThemeSize 32
      Gtk/DecorationLayout "menu:minimize,maximize,close"
      Gtk/DialogsUseHeader 0
      Gtk/EnableAnimations 1
      Gtk/EnablePrimaryPaste 1
      Gtk/FileChooserBackend "gio"
      Gtk/FontName "UbuntuMono Nerd Font Mono 15"
      Gtk/IMModule ""
      Gtk/IMPreeditStyle "callback"
      Gtk/IMStatusStyle "callback"
      Gtk/KeyThemeName "Default"
      Gtk/MenuBarAccel "F10"
      Gtk/MenuImages 1
      Gtk/ShellShowsAppMenu 0
      Gtk/ShellShowsMenubar 0
      Gtk/ShowInputMethodMenu 1
      Gtk/ShowUnicodeMenu 1
      Gtk/ToolbarIconSize "large-toolbar"
      Gtk/ToolbarStyle "both-horiz"
      Net/CursorBlink 1
      Net/CursorBlinkTime 1200
      Net/DndDragThreshold 8
      Net/DoubleClickTime 400
      Net/EnableEventSounds 0
      Net/EnableInputFeedbackSounds 0
      Net/FallbackIconTheme "mate"
      Net/IconThemeName "Numix-Circle"
      Net/SoundThemeName "__no_sounds"
      Net/ThemeName "NumixSolarizedDarkGreen"

      Xft/DPI 98433

    */
    "Net/ThemeName" = "NumixSolarizedDarkGreen";
    "Xft/Antialias" = true;
    "Xft/HintStyle" = "hintslight";
    "Xft/Hinting" = true;
    "Xft/RGBA" = "rgb";
    "Xft/lcdfilter" = "lcddefault";
  };

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
    # https://github.com/didactiklabs/nixbook/blob/main/homeManagerModules/hyprland/hyprlockConfig.nix
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

    input-field = [{
      size = "400, 50";
      position = "0, -80";
      monitor = "";
      dots_center = true;
      fade_on_empty = false;
      font_family = "UbuntuMono Nerd Font Mono";
      font_size = 20;
      font_color = "rgb(131, 148, 150)";
      inner_color = "rgb(0, 43, 54)";
      outer_color = "rgb(131, 148, 150)";
      outline_thickness = 1;
      hide_input = false;
      placeholder_text = "$USER";
      shadow_passes = 2;
    }];

    label = [
      {
        text = ''cmd[update:1000] date +"%T %:z"'';
        position = "0, -400";
        font_size = 50;
        font_color = "rgb(131, 148, 150)";
        font_family = "UbuntuMono Nerd Font Mono";
        halign = "center";
        valign = "top";
      }
    ];
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  wayland.windowManager.hyprland.systemd.extraCommands = [
    "systemctl --user stop hyprland-session.target"
    "systemctl --user start hyprland-session.target"
    "systemctl --user start nixos-fake-graphical-session.target"
  ];
  wayland.windowManager.hyprland.systemd.enableXdgAutostart = true;
  wayland.windowManager.hyprland.xwayland.enable = true;
  wayland.windowManager.hyprland.settings = {

    exec-once = [
      "hdrop -b $terminal"
    ];

    env = [
      "XCURSOR_SIZE,${cursorsize}"
      "HYPRCURSOR_SIZE,${cursorsize}"
      "WLR_XWAYLAND,${pkgs.xwayland}/bin/Xwayland"
      "GDK_BACKEND,wayland,x11,*"
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "SDL_VIDEODRIVER,waylan"
      "CLUTTER_BACKEND,wayland"
    ];

    xwayland.force_zero_scaling = true;
    # xwayland:use_nearest_neighbor
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
      "$mainMod, Left, movefocus, l"
      "$mainMod, Right, movefocus, r"
      "$mainMod, Up, movefocus, u"
      "$mainMod, Down, movefocus, d"

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

      "Control_L&Alt_L, Delete, exec, wlogout"

      "Control_L&Alt_L, Right, workspace, +1"
      "Control_L&Alt_L, Left, workspace, -1"

      # "Control_L&Shift_L, Q, exit"
      "Control_L&Shift_L, Return, exec, $terminal"

      "$mainMod&Control_L&Alt_L, Right, movetoworkspace, +1"
      "$mainMod&Control_L&Alt_L, Left, movetoworkspace, -1"

      "Control_L, grave, exec, hdrop -b tilix"
    ];

    bindm = [
      # mouse movements
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      # "$mainMod ALT, mouse:272, resizewindow"
    ];

    # binds = [
    #   "Control_L&Alt_L, Delete, exec, wlogout"

    #   "Control_L&Alt_L, Right, workspace, +1"
    #   "Control_L&Alt_L, Left, workspace, -1"

    #   "Control_L&Shift_L, Q, exit"
    #   "Control_L&Shift_L, Return, exec, $terminal"
    # ];

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
