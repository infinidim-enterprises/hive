{ inputs, cell, ... }:

{ ... }:

{
  services.minidlna.enable = true;
  services.minidlna.openFirewall = true;
  services.minidlna.settings.mediaDirs = [ "/opt/media" ];
  services.minidlna.settings.friendly_name = "dacha";
  services.minidlna.settings.inotify = "yes";
}
