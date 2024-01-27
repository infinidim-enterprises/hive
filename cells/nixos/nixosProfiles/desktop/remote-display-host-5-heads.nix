{ inputs, cell, ... }:

# NOTE: https://upload.wikimedia.org/wikipedia/commons/6/63/Vector_Video_Standards.svg
{ pkgs, lib, ... }:
with lib;
{
  environment.systemPackages = [ pkgs.arandr ];

  networking.hosts = {
    "10.11.1.40" = [ "folfanga-1-display" ];
    "10.11.1.41" = [ "folfanga-2-display" ];
    "10.11.1.42" = [ "folfanga-3-display" ];
  };

  # njk.services.debug.remote-x11vnc.enable = true;

  services.xserver.remote-display.host.enable = true;
  services.xserver.remote-display.client.enable = false;

  # NOTE: This is the default, where hiDpi renders properly on remotes.
  services.xserver.remote-display.host.screens.desktop-full = [
    {
      # NOTE: This display is on top, above the head
      id.vnc = "FOLFANGA2";
      id.xrandr = "VIRTUAL1";
      hostName = "folfanga-2-display";
      port = "65512";
      x11vncGeometry = "1920x1200";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = 1920;
      size.y = 1200;
      pos.x = 4800;
      pos.y = 0;
    }

    {
      id.vnc = "FOLFANGA1UP";
      id.xrandr = "VIRTUAL2";
      hostName = "folfanga-1-display";
      port = "65511";
      x11vncGeometry = "1920x1080";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = 3840;
      size.y = 2160;
      pos.x = "0";
      pos.y = 1200;
    }

    {
      id.vnc = "FOLFANGAUP";
      id.xrandr = "VIRTUAL3";
      hostName = "folfanga-display";
      port = "65512";
      x11vncGeometry = "1920x1080";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = 3840;
      size.y = 2160;
      pos.x = 3840;
      pos.y = 1200;
    }

    {
      # screen size 421x237 mm
      id.vnc = "FOLFANGA3UP";
      id.xrandr = "VIRTUAL4";
      hostName = "folfanga-3-display";
      port = "65511";
      x11vncGeometry = "1920x1080";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = 3840;
      size.y = 2160;
      pos.x = 7680;
      pos.y = 1200;
    }

    {
      id.vnc = "FOLFANGA1DOWN";
      id.xrandr = "VIRTUAL5";
      hostName = "folfanga-1-display";
      port = "65512";
      x11vncGeometry = "1920x1200";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = "2560";
      size.y = "1600";
      pos.x = 1920;
      pos.y = 3360;
    }

    {
      id.vnc = "FOLFANGADOWN";
      id.xrandr = "VIRTUAL6";
      hostName = "folfanga-display";
      port = "65511";
      x11vncGeometry = "2560x1600";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = "2560";
      size.y = "1600";
      pos.x = 4480;
      pos.y = 3360;
    }

    {
      # scale factor is 0.75
      id.vnc = "FOLFANGA3DOWN";
      id.xrandr = "VIRTUAL7";
      hostName = "folfanga-3-display";
      port = "65512";
      x11vncGeometry = "1920x1200";
      x11vncExtraOpts = "-scale_cursor 1";
      size.x = "2560";
      size.y = "1600";
      pos.x = 7040;
      pos.y = 3360;
    }

    {
      id.xrandr = "HDMI1";
      size.x = "2560";
      size.y = "1600";
      pos.x = 4480;
      pos.y = 4960;
    }

    {
      id.xrandr = "DSI1";
      xrandrExtraOpts = "--primary --rotate right";
      size.x = 720;
      size.y = 1280;
      pos.x = 640;
      pos.y = 1600;
    }

  ];
  /*
    {
      id.xrandr = "DSI1";
      xrandrExtraOpts = "--primary";
      size.x = 2560;
      size.y = 1600;
      pos.x = 0;
      pos.y = 0;
    }

  */
  # DSI1
  services.xserver.remote-display.host.screens.local-only = [
    {
      id.xrandr = "DSI1";
      xrandrExtraOpts = "--primary --rotate right";
      size.y = 1280;
      size.x = 720;
      pos.x = 0;
      pos.y = 0;
    }
  ];

  services.xserver.remote-display.host.screens.local-with-hdmi = [
    {
      id.xrandr = "HDMI1";
      size.x = 2560;
      size.y = 1600;
      pos.x = 0;
      pos.y = 0;
    }

    {
      id.xrandr = "DSI1";
      xrandrExtraOpts = "--primary --rotate right";
      size.y = 1280;
      size.x = 720;
      pos.x = 640;
      pos.y = 1600;
    }
  ];

}
