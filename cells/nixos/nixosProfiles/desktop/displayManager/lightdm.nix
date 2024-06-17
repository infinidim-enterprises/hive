{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{

  services.xserver.enable = true;
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
    '';
    # services.xserver.displayManager.lightdm.extraSeatDefaults =
    #   let
    #     display-setup-script = pkgs.writeScript "display-setup-script" ''
    #       ${pkgs.redshift}/bin/redshift -r -O 3200 || true
    #       ${pkgs.xorg.xbacklight}/bin/xbacklight -set 18 || true
    #       ${pkgs.xorg.xsetroot}/bin/xsetroot -xcf ${pkgs.numix-cursor-theme}/share/icons/Numix-Cursor-Light/cursors/left_ptr 32 || true
    #       ${pkgs.xorg.xrandr}/bin/xrandr --output DSI1 --rotate right
    #     '';
    #   in
    #   ''
    #     display-setup-script=${display-setup-script}
    #   '';

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

  environment.systemPackages = with pkgs.xorg; [
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
  ];
}
