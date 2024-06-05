{ inputs, config, pkgs, profiles, suites, osConfig, lib, ... }:
with lib;
let
  isHiDpi = hasAttrByPath [ "deploy" "params" "hidpi" ] osConfig && osConfig.deploy.params.hidpi.enable;
in
{
  imports =
    [ inputs.nix-doom-emacs.hmModule ] ++
    (inputs.cells.common.lib.importers.importFolder ./.) ++
    suites.desktop ++
    suites.office ++
    [
      profiles.messengers
      profiles.multimedia.players
      profiles.pentester.traffic
      profiles.security.keybase
      profiles.security.password-store
      # FIXME: profiles.activitywatch
      profiles.browsers.firefox
      # profiles.browsers.floorp
    ] ++
    (with profiles.look-and-feel;
    [
      solarized-dark
      nerdfonts-ubuntu
      starship-prompt
      pointer-cursor
    ]) ++ (with profiles.developer; [
      # FIXME: extensions - vscode
      ruby
      nix
      direnv
      git
      javascript
      dbtools.postgresql
      dbtools.mysql
      tools
      kubernetes
      crystal
      android
      ballerina # NOTE: currently only java support
    ]);

  home.packages = with pkgs; [
    nyxt # TODO: nyxt proper config!
    tigervnc
    jekyll
    vultr-cli
    # virt-manager
    sops
  ];

  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  xdg.userDirs.extraConfig.XDG_PROJ_DIR = "$HOME/Projects";
  home.sessionVariables.XDG_PROJ_DIR = "$HOME/Projects";

  gtk.enable = true;
  gtk.gtk2.extraConfig = ''
    gtk-key-theme-name = "Emacs"
    binding "gtk-emacs-text-entry"
    {
      bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) }
    }
  '';

  dconf.enable = true;
  dconf.settings = {
    "org/mate/desktop/session".idle-delay = 15;
    "org/mate/desktop/session".show-hidden-apps = true;
    "org/mate/screensaver".mode = "blank-only";
    "org/gtk/settings/file-chooser".sort-directories-first = true;

    "org/mate/desktop/peripherals/mouse".motion-acceleration = 7;

    # TODO: have a touchpad profile instead of this
    "org/mate/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      three-finger-click = 2;
      two-finger-click = 3;
    };

    "org/mate/desktop/peripherals/keyboard/kbd" = {
      layouts = [ "us" "ru\tphonetic_YAZHERTY" ]; # "de"
      options = [ "grp\tgrp:shifts_toggle" ];
    };

    "org/mate/panel/objects/clock/prefs" = {
      format = "24-hour";
      cities = [ ''<location name="" city="Frankfurt" timezone="Europe/Berlin" latitude="50.049999" longitude="8.600000" code="EDDF" current="false"/>'' ];
    };

    "org/mate/desktop/peripherals/keyboard/indicator" = {
      show-flags = false;
    };

    # TODO: key remap should be in window manager lisp module, once it's home-manager based!
    "org/mate/settings-daemon/plugins/media-keys".power = "<Primary><Alt>End";
    "org/mate/desktop/interface".window-scaling-factor = if isHiDpi then 2 else 1;
  };

  programs.rofi.enable = true;
  programs.rofi.location = "center";
  programs.rofi.plugins = with pkgs; [ rofi-systemd rofi-calc ];
  programs.rofi.cycle = true;

  # NOTE: PASSWORD_STORE_KEY can use multiple fingerprints separated by a whitespace
  programs.password-store.settings.PASSWORD_STORE_KEY = "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE";

  services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;
}
