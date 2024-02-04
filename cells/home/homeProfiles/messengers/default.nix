{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: move it into a separate profile
    bisq-desktop

    tdesktop
    # TODO: signald
    signal-desktop
    element-desktop
    linphone
    # baresip
    jitsi
    qtox
    utox
  ];
}
