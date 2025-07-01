{ ... }:

{ user }:
{ pkgs, ... }:
let
  dbusServiceFile = pkgs.writeTextFile rec {
    name = "org.freedesktop.GeoClue2.Provider.MyProvider";
    destination = "/share/dbus-1/system.d/${name}.conf";
    text = ''
      <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy user="${user}">
        <allow own="org.freedesktop.GeoClue2.Provider.MyProvider"/>
        <allow send_destination="org.freedesktop.GeoClue2"/>
        <allow send_interface="org.freedesktop.GeoClue2.Manager"/>
        <allow send_interface="org.freedesktop.GeoClue2.Provider"/>
        </policy>
      </busconfig>
    '';
  };

in
{ services.dbus.packages = [ dbusServiceFile ]; }
