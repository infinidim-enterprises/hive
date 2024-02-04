# TODO: perhaps replace with https://wezfurlong.org/wezterm/multiplexing.html
{ config, lib, pkgs, ... }:
{

  home.packages = [ pkgs.tilix ];
  programs.rofi.terminal = lib.mkIf config.programs.rofi.enable "${pkgs.tilix}/bin/tilix";
  dconf.settings = {
    # https://github.com/gnunn1/tilix/blob/master/data/gsettings/com.gexperts.Tilix.gschema.xml

    "com/gexperts/Tilix" = {
      auto-hide-mouse = true;
      copy-on-select = true;
      new-instance-mode = "new-session";
      new-window-inherit-state = true;
      prompt-on-close = true;
      prompt-on-close-process = false;
      quake-show-on-all-workspaces = true;
      quake-specific-monitor = 0;
      quake-width-percent = 80;
      terminal-title-show-when-single = false;
      warn-vte-config-issue = false;
      window-style = "borderless";
    };

    "com/gexperts/Tilix/keybindings" = {
      app-new-session = "<Primary><Shift>Return";
      app-preferences = "<Primary><Shift>p";
      session-close = "<Primary>q";
      session-name = "<Primary><Shift>a";
      terminal-find-previous = "disabled";
      terminal-paste = "<Primary>y";
      terminal-select-all = "disabled";
      win-switch-to-next-session = "<Primary><Shift>l";
      win-switch-to-previous-session = "<Primary><Shift>h";
    };

    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      badge-color-set = false;
      bold-color-set = false;
      cursor-colors-set = false;
      highlight-colors-set = false;
      select-by-word-chars = "-,./?%&#:_~";
      show-scrollbar = false;
      use-system-font = false;
      use-theme-colors = false;
      visible-name = "Default";
      login-shell = true;
    };
  };
}
