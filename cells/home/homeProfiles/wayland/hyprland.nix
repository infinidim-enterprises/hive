{ osConfig, config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    isInt
    toString
    concatStringsSep
    splitString
    fileContents
    tail;
  cursorsize =
    if config.gtk.enable && (isInt config.gtk.cursorTheme.size)
    then toString config.gtk.cursorTheme.size
    else "24";
  remove_shebang = txt: concatStringsSep "\n" (tail (splitString "\n" txt));
  focus_monitor = pkgs.writeShellApplication {
    name = "focus_monitor";
    runtimeInputs = with pkgs; [ jq hyprland ];
    text = remove_shebang (fileContents ./focus_monitor.sh);
  };
  volume_control = pkgs.writeShellApplication {
    name = "volume_control";
    runtimeInputs = with pkgs; [ hyprland gawk pulseaudio gnugrep ];
    text = remove_shebang (fileContents ./volume_control.sh);
  };

in
{
  services.network-manager-applet.enable = osConfig.networking.networkmanager.enable;
  systemd.user.services.network-manager-applet.Unit.After = [ "waybar.service" ];
  # TODO: investigate mate-wayland-session with hyprland

  # NOTE: kinda need a filemanager
  home.packages = with pkgs; [
    mate.caja-with-extensions
    focus_monitor
    volume_control
  ];

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

    # FIXME: "org/gnome/system/wsdd".display-mode = "disabled";
  };

  # TODO: maybe this instead? https://github.com/savedra1/clipse
  services.cliphist.enable = true;
  services.cliphist.allowImages = true;
  services.cliphist.systemdTarget = "wayland-session@Hyprland.target";
  systemd.user.services.cliphist.Unit.After = [ "waybar.service" ];
  systemd.user.services.cliphist-images.Unit.After = [ "cliphist.service" ];

  services.gammastep.enable = true;
  services.gammastep.tray = true;
  services.gammastep.provider = "manual";
  services.gammastep.latitude = 44.4152772;
  services.gammastep.longitude = 26.0422636;
  services.gammastep.temperature.day = 4200;
  services.gammastep.temperature.night = 3600;
  services.gammastep.settings = {
    general.adjustment-method = "wayland";
    general.fade = 1;
  };

  systemd.user.services.xsettingsd.Unit.After = [ "wayland-wm@Hyprland.service" ];
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

  systemd.user.services.hypridle.Unit.After = [ "waybar.service" ];
  services.hypridle.enable = true;
  services.hypridle.settings = {
    general = {
      before_sleep_cmd = "brightnessctl --save && brightnessctl set 1% && loginctl lock-session";
      # && systemctl --user restart gammastep.service
      after_sleep_cmd = "hyprctl dispatch dpms on && brightnessctl --restore";
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
      grace = 10;
      hide_cursor = true;
      no_fade_in = false;
      no_fade_out = false;
    };

    background = [
      {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }
    ];

    input-field = [{
      size = "250, 50";
      position = "0, -20";
      monitor = "";
      dots_center = true;
      fade_on_empty = false;
      font_family = "UbuntuMono Nerd Font Mono";
      font_size = 30;
      font_color = "rgb(131, 148, 150)";
      inner_color = "rgb(0, 43, 54)";
      outer_color = "rgb(131, 148, 150)";
      outline_thickness = 1;
      hide_input = false;
      placeholder_text = "$USER@${osConfig.networking.fqdn}";
      shadow_passes = 2;
    }];

    label = [
      {
        text = ''cmd[update:1000] date +"%T"''; #  %:z
        position = "0, 0";
        font_size = 50;
        font_color = "rgb(131, 148, 150)";
        font_family = "UbuntuMono Nerd Font Mono";
        halign = "center";
        valign = "top";
      }
    ];
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = !osConfig.programs.hyprland.withUWSM;
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];

  # wayland.windowManager.hyprland.systemd.extraCommands = [
  #   "systemctl --user stop hyprland-session.target"
  #   "systemctl --user start hyprland-session.target"
  #   "systemctl --user start nixos-fake-graphical-session.target"
  # ];

  wayland.windowManager.hyprland.systemd.enableXdgAutostart = true;
  wayland.windowManager.hyprland.xwayland.enable = osConfig.programs.hyprland.xwayland.enable;
  wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
    # hycov
    # virtual-desktops
    hyprexpo
    hy3
  ];

  wayland.windowManager.hyprland.settings = {
    # https://github.com/SolDoesTech/HyprV4 - bunch of examples
    # exec-once = [ "hdrop -b $terminal" ]; # NOTE: conflicts with hy3

    exec-once = [ "brightnessctl set 30%" ];

    env = [
      "XCURSOR_THEME,${config.gtk.cursorTheme.name}"
      "XCURSOR_SIZE,${cursorsize}"
      # "HYPRCURSOR_SIZE,${cursorsize}"
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
      layout = "hy3"; # "dwindle";
    };

    decoration = {
      rounding = 0;

      # Change transparency of focused and unfocused windows
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      # drop_shadow = false;
      blur.enabled = false;
    };

    animations.enabled = false;
    animations.first_launch_animation = false;

    # dwindle.pseudotile = true;
    # dwindle.preserve_split = true; # You probably want this

    misc.force_default_wallpaper = 0;
    misc.disable_hyprland_logo = true;
    misc.disable_splash_rendering = true;
    misc.font_family = "UbuntuMono Nerd Font Mono";
    misc.background_color = "0x002b36";

    cursor.hide_on_key_press = true;

    input.kb_layout = "us, ru";
    input.kb_variant = ",phonetic_YAZHERTY";
    input.kb_options = "grp:shifts_toggle";

    input.follow_mouse = 0;

    input.sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    input.accel_profile = "adaptive";
    input.touchpad.natural_scroll = false;

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures.workspace_swipe = false;

    "$masterMod" = "SUPER";
    "$terminal" = "tilix";
    "$menu" = "wofi --show drun";
    "$fileManager" = "caja --no-desktop";

    plugin.hyprexpo.columns = 3;
    plugin.hyprexpo.gap_size = 5;
    plugin.hyprexpo.bg_col = "rgb(0, 43, 54)";
    plugin.hyprexpo.workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
    plugin.hyprexpo.enable_gesture = false; # laptop touchpad

    # plugin.hycov = {
    #   overview_gappo = 10; # gaps width from screen edge
    #   overview_gappi = 10; # gaps width from clients
    #   enable_click_action = 1; # enable mouse left button jump and right button kill in overview mode
    #   # enable_hotarea = 1; # enable mouse cursor hotarea, when cursor enter hotarea, it will toggle overview
    #   # hotarea_monitor = "all"; # monitor name which hotarea is in, default is all
    #   # hotarea_pos = 1; # position of hotarea (1: bottom left, 2: bottom right, 3: top left, 4: top right)
    #   # hotarea_size = 10; # hotarea size, 10x10
    #   # swipe_fingers = 4; # finger number of gesture,move any directory
    #   # move_focus_distance = 100; # distance for movefocus,only can use 3 finger to move
    #   enable_gesture = 0; # enable gesture
    #   auto_exit = 1; # enable auto exit when no client in overview
    #   auto_fullscreen = 0; # auto make active window maximize after exit overview
    #   only_active_workspace = 0; # only overview the active workspace
    #   only_active_monitor = 0; # only overview the active monitor
    #   enable_alt_release_exit = 0; # alt swith mode arg,see readme for detail
    #   alt_replace_key = "Alt_L"; # alt swith mode arg,see readme for detail
    #   alt_toggle_auto_next = 0; # auto focus next window when toggle overview in alt swith mode
    #   click_in_cursor = 1; # when click to jump,the target windwow is find by cursor, not the current foucus window.
    #   hight_of_titlebar = 0; # height deviation of title bar height
    #   show_special = 0; # show windwos in special workspace in overview.
    #   raise_float_to_top = 1; # raise the window that is floating before to top after leave overview mode
    # };

    plugin.hy3 = {
      # disable gaps when only one window is onscreen
      # 0 - always show gaps
      # 1 - hide gaps with a single window onscreen
      # 2 - 1 but also show the window border
      no_gaps_when_only = 2; # default: 0

      # policy controlling what happens when a node is removed from a group,
      # leaving only a group
      # 0 = remove the nested group
      # 1 = keep the nested group
      # 2 = keep the nested group only if its parent is a tab group
      node_collapse_policy = 2; # default: 2

      # offset from group split direction when only one window is in a group
      group_inset = 10; # default: 10

      # if a tab group will automatically be created for the first window spawned in a workspace
      tab_first_window = false;

      # tab group settings
      tabs = {
        # height of the tab bar
        height = 10; # default: 15

        # padding between the tab bar and its focused node
        padding = 3; # default: 5

        # the tab bar should animate in/out from the top instead of below the window
        from_top = false; # default: false

        # rounding of tab bar corners
        rounding = 3; # default: 3

        # render the window title on the bar
        render_text = false; # default: true

        # center the window title
        text_center = false; # default: false

        # font to render the window title with
        # text_font = <string> # default: Sans

        # height of the window title
        # text_height = <int> # default: 8

        # left padding of the window title
        text_padding = 3; # default: 3

        # active tab bar segment color
        # "col.active" = "<color>"; # default: 0xff32b4ff

        # urgent tab bar segment color
        # "col.urgent" = "<color>"; # default: 0xffff4f4f

        # inactive tab bar segment color
        # "col.inactive" = "<color>"; # default: 0x80808080

        # active tab bar text color
        # "col.text.active" = "<color>"; # default: 0xff000000

        # urgent tab bar text color
        # "col.text.urgent" = "<color>"; # default: 0xff000000

        # inactive tab bar text color
        # "col.text.inactive" = "<color>"; # default: 0xff000000
      };

      # autotiling settings
      autotile = {
        # enable autotile
        enable = false; # default: false

        # make autotile-created groups ephemeral
        ephemeral_groups = true; # default: true

        # if a window would be squished smaller than this width, a vertical split will be created
        # -1 = never automatically split vertically
        # 0 = always automatically split vertically
        # <number> = pixel height to split at
        trigger_width = 0; # default: 0

        # if a window would be squished smaller than this height, a horizontal split will be created
        # -1 = never automatically split horizontally
        # 0 = always automatically split horizontally
        # <number> = pixel height to split at
        trigger_height = 0; # default: 0

        # a space or comma separated list of workspace ids where autotile should be enabled
        # it's possible to create an exception rule by prefixing the definition with "not:"
        # workspaces = 1,2 # autotiling will only be enabled on workspaces 1 and 2
        # workspaces = not:1,2 # autotiling will be enabled on all workspaces except 1 and 2
        workspaces = "not:1,2,3"; # default: all
      };
    };

    # plugin.virtual-desktops = {
    #   names = "1:master, 2:emacs, 3:web";
    #   cycleworkspaces = 1;
    #   rememberlayout = "size";
    #   notifyinit = 0;
    #   verbose_logging = 0;
    # };

    workspace = [
      "1, defaultName:Master"
      "2, defaultName:Emacs"
      "3, defaultName:Web"
    ];

    # debug.disable_logs = false;
    /*
      binde =
      binde = , XF86AudioRaiseVolume, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

      binde =
      binde = , XF86AudioLowerVolume, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

      bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bind = , XF86AudioMute, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

    */
    binde = [
      ", XF86AudioRaiseVolume, execr, volume_control raise"
      ", XF86AudioLowerVolume, execr, volume_control lower"

      ", XF86MonBrightnessUp, execr, brightnessctl set 10%+"
      ", XF86MonBrightnessDown, execr, brightnessctl set 10%-"
    ];

    bind = [
      "$masterMod, Return, fullscreen, 0"
      "$masterMod, F, exec, $fileManager"
      "$masterMod Alt_L, F, togglefloating"
      # "$masterMod, P, pseudo"
      # "$masterMod, J, togglesplit"

      "$masterMod, grave, hyprexpo:expo, toggle" # hyprexpo plugin

      # Move focus with mainMod + arrow keys
      # "$masterMod, Left, movefocus, l"
      # "$masterMod, Right, movefocus, r"
      # "$masterMod, Up, movefocus, u"
      # "$masterMod, Down, movefocus, d"
      "$masterMod, Left, hy3:movefocus, left"
      "$masterMod, Right, hy3:movefocus, right"
      "$masterMod, Up, hy3:movefocus, up"
      "$masterMod, Down, hy3:movefocus, down"

      "$masterMod SHIFT, Up, hy3:changefocus, raise"
      "$masterMod SHIFT, Down, hy3:changefocus, lower"

      # Move the window itself
      # "$masterMod Alt_L, Left, movewindow, l"
      # "$masterMod Alt_L, Right, movewindow, r"
      # "$masterMod Alt_L, Up, movewindow, u"
      # "$masterMod Alt_L, Down, movewindow, d"

      "$masterMod Alt_L, Left, hy3:movewindow, left, once"
      "$masterMod Alt_L, Right, hy3:movewindow, right, once"
      "$masterMod Alt_L, Up, hy3:movewindow, up, once"
      "$masterMod Alt_L, Down, hy3:movewindow, down, once"

      "$masterMod Alt_L SHIFT, Left, hy3:movewindow, left, once, visible"
      "$masterMod Alt_L SHIFT, Right, hy3:movewindow, right, once, visible"
      "$masterMod Alt_L SHIFT, Up, hy3:movewindow, up, once, visible"
      "$masterMod Alt_L SHIFT, Down, hy3:movewindow, down, once, visible"

      # TODO: "ALT,tab,hycov:toggleoverview"

      "Alt_L, Tab, cyclenext"
      "$masterMod, Tab, focuscurrentorlast"

      # Example special workspace (scratchpad)
      # "$masterMod, S, togglespecialworkspace, magic"
      # "$masterMod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      # "$masterMod, mouse_down, workspace, e+1"
      # "$masterMod, mouse_up, workspace, e-1"

      "Control_L Alt_L, Delete, exec, ${config.programs.wlogout.command}"

      # focusworkspaceoncurrentmonitor ?
      "Control_L Alt_L, Right, workspace, +1"
      "Control_L Alt_L, Left, workspace, -1"
      "Control_L Alt_L, Up, workspace, +1"
      "Control_L Alt_L, Down, workspace, -1"

      # focus monitor
      "$masterMod Control_L, Right, execr, focus_monitor right"
      "$masterMod Control_L, Left, execr, focus_monitor left"
      "$masterMod Control_L, Up, execr, focus_monitor up"
      "$masterMod Control_L, Down, execr, focus_monitor down"


      # "Control_L&Shift_L, Q, exit"
      "Control_L Shift_L, Return, exec, $terminal"

      "$masterMod Control_L Alt_L, Right, movetoworkspace, +1"
      "$masterMod Control_L Alt_L, Left, movetoworkspace, -1"
      "$masterMod Control_L Alt_L, Up, movetoworkspace, +1"
      "$masterMod Control_L Alt_L, Down, movetoworkspace, -1"

      # "Control_L, grave, exec, hdrop -b tilix"
      ", XF86AudioMute, execr, volume_control toggle"
      ", Print, exec, grim -g $(slurp) - | swappy -f -" # take a screenshot
    ];

    bindm = [
      # mouse movements
      "$masterMod, mouse:272, movewindow"
      "$masterMod, mouse:273, resizewindow"
      # "$masterMod ALT, mouse:272, resizewindow"
    ];

    # binds = [
    #   "Control_L&Alt_L, Delete, exec, wlogout"

    #   "Control_L&Alt_L, Right, workspace, +1"
    #   "Control_L&Alt_L, Left, workspace, -1"

    #   "Control_L&Shift_L, Q, exit"
    #   "Control_L&Shift_L, Return, exec, $terminal"
    # ];

    # RULES:
    # animation popin,class:^(kitty)$,title:^(update-sys)$
    # https://github.com/MathisP75/summer-day-and-night/blob/main/hypr/hyprland.conf

    windowrulev2 = [
      "suppressevent maximize, class:.*"

      "float, class:^(gcr-prompter)$"
      "dimaround, class:^(gcr-prompter)$"
      "stayfocused, class:^(gcr-prompter)$"

      "float, title:^(Open File)$"
      "size 800 600, title:^(Open File)$"
      "move 100 100, title:^(Open File)$"

      "float, class:^(pavucontrol)$"

      "float, class:^(Vlc)$, title:^(Open Directory|Select one or multiple files)$"
      "size 800 600, class:^(Vlc)$, title:^(Open Directory|Select one or multiple files)$"
      "move 100 100, class:^(Vlc)$, title:^(Open Directory|Select one or multiple files)$"
      "stayfocused, class:^(Vlc)$, title:^(Open Directory|Select one or multiple files)$"
      "dimaround, class:^(Vlc)$, title:^(Open Directory|Select one or multiple files)$"

      "float, class:^(evince)$, title:^(Print)$"
      "size 800 600, class:^(evince)$, title:^(Print)$"
      # "move 100 100, class:^(evince)$, title:^(Print)$"
      "stayfocused, class:^(evince)$, title:^(Print)$"
      "dimaround, class:^(evince)$, title:^(Print)$"

      "float, class:^(net.code-industry.masterpdfeditor5)$, title:^(Print)$"
      "size 600 700, class:^(net.code-industry.masterpdfeditor5)$, title:^(Print)$"
      "move 100 15, class:^(net.code-industry.masterpdfeditor5)$, title:^(Print)$"
      "stayfocused, class:^(net.code-industry.masterpdfeditor5)$, title:^(Print)$"
      "dimaround, class:^(net.code-industry.masterpdfeditor5)$, title:^(Print)$"


    ];
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind = Control_L, apostrophe, submap, chords
    submap = chords

    bind = Control_L, period, exec, $menu
    bind = Control_L, period, submap, reset

    bind = SHIFT, k, hy3:killactive
    bind = SHIFT, k, submap, reset

    bind = Control_L, y, exec, cliphist list | wofi --show dmenu | cliphist decode | xargs wtype
    bind = Control_L, y, submap, reset
    bind = , y, exec, cliphist list | wofi --show dmenu | cliphist decode | wl-copy
    bind = , y, submap, reset

    bind = , 3, hy3:makegroup, h
    bind = , 3, submap, reset
    bind = , 2, hy3:makegroup, v
    bind = , 2, submap, reset
    bind = , Tab, hy3:makegroup, tab
    bind = , Tab, submap, reset
    bind = Control_L, Tab, hy3:changegroup, toggletab
    bind = Control_L, Tab, submap, reset

    bind = , Return, hy3:setephemeral, false
    bind = , Return, submap, reset
    bind = Control_L, Return, hy3:setephemeral, true
    bind = Control_L, Return, submap, reset

    bind = Control_L, s, hy3:changegroup, opposite
    bind = Control_L, s, submap, reset
    bind = SHIFT, q, hy3:expand, expand
    bind = SHIFT, q, submap, reset
    bind = , q, hy3:expand, base
    bind = , q, submap, reset

    bind = , k, killactive
    bind = , k, submap, reset
    bind = , e, exec, [ workspace 2 silent ] emacsclient -c
    bind = , e, submap, reset

    bind = Control_L, g, submap, reset
    submap = reset
  '';
  #   bind = $masterMod, apostrophe, submap, clipboard
  # submap = clipboard
  # submap = reset
}
