{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: move it into a separate profile
    bisq-desktop

    tdesktop
    # TODO: signald # Unofficial daemon for interacting with Signal
    signal-desktop
    element-desktop
    linphone
    baresip
    jitsi
    qtox
    utox
    localsend # Open source cross-platform alternative to AirDrop
  ];
}
