{ inputs, cell, ... }:

{ ... }:
# fs.inotify.max_user_watches=524288
{
  services.minidlna.enable = true;
  services.minidlna.openFirewall = true;
  services.minidlna.settings.media_dir = [ "V,/opt/media" ];
  services.minidlna.settings.friendly_name = "dacha";
  services.minidlna.settings.inotify = "yes";

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
}
