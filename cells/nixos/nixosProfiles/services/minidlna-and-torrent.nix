{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    map
    last
    mkForce
    mkMerge
    splitString
    concatStringsSep;
  download-dir = "/opt/media";
  media_dirs =
    with config.systemd.services.minidlna.serviceConfig;
    map
      (e: "chown --recursive ${User}:${Group} "
        + (last (splitString "," e)))
      config.services.minidlna.settings.media_dir;

in
mkMerge [
  { boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288; }

  {
    services.minidlna.enable = true;
    services.minidlna.openFirewall = true;
    services.minidlna.settings.media_dir = [ "V,${download-dir}" ];
    services.minidlna.settings.friendly_name = "dacha";
    services.minidlna.settings.inotify = "yes";

    systemd.services.minidlna-fix-perms.partOf = [ "minidlna.service" ];
    systemd.services.minidlna-fix-perms.script = ''
      ${concatStringsSep "\n" media_dirs}
    '';

    # systemd.services.minidlna.wantedBy = lib.mkForce [ ]; # NOTE: Don't start minidlna by default
    systemd.services.minidlna.after = [ "minidlna-fix-perms.service" ];
    systemd.services.minidlna.preStart = ''
      rm -rf ${config.services.minidlna.settings.db_dir}/*
    '';
  }

  {
    services.transmission.enable = true;
    services.transmission.user = "minidlna";
    services.transmission.group = "minidlna";
    services.transmission.package = pkgs.transmission_4;
    services.transmission.webHome = inputs.cells.common.packages.transmissionic;
    services.transmission.openRPCPort = true;
    services.transmission.openFirewall = true;
    services.transmission.settings = {
      inherit download-dir;
      message-level = 0;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "192.168.1.*";
      incomplete-dir = "${download-dir}/.incomplete";
      incomplete-dir-enabled = true;
      peer-limit-global = 500;
      peer-limit-per-torrent = 100;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 5;
    };
  }

  {
    systemd.services.minidlna.after = [ "opt-media.mount" ];
    systemd.services.transmission.after = [ "opt-media.mount" ];
    systemd.mounts = [{
      what = "LABEL=torrents";
      where = "/opt/media";
      type = "ext4";
      options = "defaults,noatime";
      before = [ "minidlna.service" "transmission.service" ];
      requiredBy = [ "minidlna.service" "transmission.service" ];
    }];
  }

  # {
  #   services.udev.extraRules = ''
  #     # Start services when the "torrents" disk is attached
  #     ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="torrents", TAG+="systemd", ENV{SYSTEMD_WANTS}="minidlna.service transmission.service"

  #     # Stop services when the "torrents" disk is removed
  #     ACTION=="remove", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="torrents", RUN+="${pkgs.systemd}/bin/systemctl stop minidlna.service transmission.service"
  #   '';
  # }
]
