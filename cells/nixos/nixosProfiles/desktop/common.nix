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

  services.displayManager.logToFile = false;
  services.displayManager.logToJournal = false;

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

    #
    # export PATH=''${lib.makeBinPath reqPkgs}:$PATH
    # logger -t DM-SESSION 'x11vnc'
    #   x11vnc -ping 3 \
    #          -noipv6 \
    #          -cursorpos \
    #          -repeat \
    #          -noxdamage \
    #          -shared \
    #          -forever \
    #          -nolookup \
    #          -nopw \
    #          -norc \
    #          -nonc \
    #          -geometry 1920x1080 \
    #          -display $DISPLAY \
    #          -desktop DEBUG \
    #          -rfbport 44444 & x11vncPID=$!
    #   logger -t DM-SESSION "x11vnc with PID $x11vncPID"

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

  xdg.mime.enable = true;

  qt.enable = true;
  qt.style = "gtk2";
  qt.platformTheme = "gtk2";

  programs.light.enable = true;

  hardware.sane.enable = true;
  hardware.acpilight.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-module-xrdp ];

  services.opensnitch.enable = false; # NOTE: opensnitch SUCKS!

  services.colord.enable = true;
  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.accounts-daemon.enable = true;
  services.packagekit.enable = true;
  services.gnome.gnome-keyring.enable = lib.mkForce false;
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
