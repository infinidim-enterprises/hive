{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    map
    last
    mkForce
    splitString
    concatStringsSep;
in
{
  services.minidlna.enable = true;
  services.minidlna.openFirewall = true;
  services.minidlna.settings.media_dir = [ "V,/opt/media" ];
  services.minidlna.settings.friendly_name = "dacha";
  services.minidlna.settings.inotify = "yes";

  systemd.services.minidlna-fix-perms.script =
    let
      dirs =
        with config.systemd.services.minidlna.serviceConfig;
        map
          (e: "chown --recursive ${User}:${Group} "
            + (last (splitString "," e)))
          config.services.minidlna.settings.media_dir;
    in
    ''
      ${concatStringsSep "\n" dirs}
    '';

  systemd.services.minidlna.wantedBy = lib.mkForce [ ]; # NOTE: Don't start minidlna by default
  systemd.services.minidlna.after = [ "minidlna-fix-perms.service" ];
  systemd.services.minidlna.preStart = ''
    rm -rf ${config.services.minidlna.settings.db_dir}/*
  '';

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
}
