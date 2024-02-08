{ inputs, cell, ... }:

{ pkgs, lib, profiles, ... }:
{
  home-manager.sharedModules = [{
    programs.zsh.enableVteIntegration = true;
    programs.bash.enableVteIntegration = true;
  }];

  imports = [
    # inputs.cells.bootstrap.nixosProfiles.core.kernel.binfmt
    cell.nixosProfiles.desktop.fonts
    # cell.nixosProfiles.desktop.printer-kyocera
  ];

  services.xserver.displayManager.job.logToFile = false;
  services.xserver.displayManager.job.logToJournal = false;

  services.xserver.enable = true;
  # services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
  services.xserver.updateDbusEnvironment = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk.theme.package = pkgs.numix-solarized-gtk-theme;
    greeters.gtk.theme.name = "NumixSolarizedDarkGreen";
    greeters.gtk.iconTheme.name = "Numix-Circle";
    greeters.gtk.iconTheme.package = pkgs.numix-icon-theme-circle;
    greeters.gtk.clock-format = "[%d %b %G] %H:%M %A [week %U]";
    extraSeatDefaults = ''
      allow-guest=false
      greeter-hide-users=true
      greeter-show-manual-login=true
      display-setup-script=${pkgs.writeScript "display-setup-script" ''
        # ${pkgs.redshift}/bin/redshift -r -O 3200 || true
        ${pkgs.xorg.xbacklight}/bin/xbacklight -set 18 || true
        ${pkgs.xorg.xsetroot}/bin/xsetroot -xcf ${pkgs.numix-cursor-theme}/share/icons/Numix-Cursor-Light/cursors/left_ptr 32 || true
        ${pkgs.xorg.xrandr}/bin/xrandr --output DSI1 --rotate right
      ''}
    '';

    greeters.gtk.indicators = [
      "~host"
      "~spacer"
      "~clock"
      "~spacer"
      "~session"
      "~language"
      "~a11y"
      "~power"
    ];

    # FIXME: Font for greeter
    greeters.gtk.extraConfig = ''
      # TODO: just try if it's a valid option
      # key-theme-name=Emacs
      background = #002b36
      font-name=Ubuntu Mono Nerd Font Complete Mono 24
      xft-antialias=true
      xft-hintstyle=hintslight
      xft-rgba=rgb
      cursor-theme-name=Numix-Cursor-Light
    '';
  };

  security.polkit.enable = true;
  # security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

  programs.nix-ld.enable = true;
  programs.droidcam.enable = true;
  programs.kdeconnect.enable = true;

  xdg.mime.enable = true;

  qt.enable = true;
  qt.style = "gtk2";
  qt.platformTheme = "gtk2";

  programs.light.enable = true;

  hardware.sane.enable = true;
  hardware.acpilight.enable = true;
  hardware.pulseaudio.enable = true;
  # FIXME: hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];

  services.opensnitch.enable = false; # NOTE: opensnitch SUCKS!

  services.colord.enable = true;
  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.accounts-daemon.enable = true;
  services.packagekit.enable = true;
  # services.gnome.gnome-keyring.enable = lib.mkForce false;
  services.gnome.at-spi2-core.enable = true;
  services.gnome.glib-networking.enable = true;
  services.redshift.enable = true;
  # services.redshift.brightness.day = "10";
  services.redshift.temperature.day = 4200;
  # services.redshift.brightness.night = "10";
  services.redshift.temperature.night = 3600;

  environment.systemPackages = with pkgs; [
    pulseaudio-ctl

    gnome.adwaita-icon-theme
    gnome.dconf-editor

    numix-cursor-theme
    numix-icon-theme-circle
    numix-icon-theme

    libnotify

    desktop-file-utils
    xdg_utils
    xdg-user-dirs
    xdgmenumaker

    # Misc utils
    xfontsel
    xdotool
    xsel
    evtest

  ] ++ (with xorg; [
    xcursorthemes
    setxkbmap
    xauth
    xbacklight
    xdpyinfo
    xev
    xhost
    xinput
    xkbcomp
    xkbutils
    xev
    xmessage
    xmodmap
    xprop
    xrandr
    xrdb
    xset
    xsetroot
    xwininfo
  ]);
}
