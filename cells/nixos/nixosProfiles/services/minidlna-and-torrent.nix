{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    map
    last
    mkMerge
    splitString
    concatStringsSep;
  download-dir = "/opt/media";
  # media_dirs =
  #   with config.systemd.services.jellyfin.serviceConfig;
  #   map
  #     (e: "chown --recursive ${User}:${Group} "
  #       + (last (splitString "," e)))
  #     config.services.minidlna.settings.media_dir;

in
mkMerge [
  { boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288; }

  {
    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;

    systemd.services.jellyfin-fix-perms.wantedBy = [ "jellyfin.service" ];
    systemd.services.jellyfin-fix-perms.script =
      with config.systemd.services.jellyfin.serviceConfig;
      ''
        chown --recursive ${User}:${Group} ${download-dir}
      '';

    systemd.services.jellyfin.after = [ "jellyfin-fix-perms.service" ];
  }

  (with config.systemd.services.jellyfin.serviceConfig;  {
    services.sonarr.enable = true;
    services.sonarr.user = User;
    services.sonarr.group = Group;
    services.sonarr.openFirewall = true;
    services.sonarr.dataDir = download-dir + "/sonarr";
    systemd.services.sonarr.after = [ "jellyfin.service" ];

    services.prowlarr.enable = true;
    services.prowlarr.openFirewall = true;
    systemd.services.prowlarr.after = [ "jellyfin.service" ];
  })

  # {
  #   services.minidlna.enable = true;
  #   services.minidlna.openFirewall = true;
  #   services.minidlna.settings.media_dir = [ "V,${download-dir}" ];
  #   services.minidlna.settings.friendly_name = "dacha";
  #   services.minidlna.settings.inotify = "yes";

  #   systemd.services.minidlna-fix-perms.wantedBy = [ "minidlna.service" ];
  #   systemd.services.minidlna-fix-perms.script = ''
  #     ${concatStringsSep "\n" media_dirs}
  #   '';

  #   systemd.services.minidlna.after = [ "minidlna-fix-perms.service" ];
  #   systemd.services.minidlna.preStart = ''
  #     rm -rf ${config.services.minidlna.settings.db_dir}/*
  #   '';
  # }

  {
    services.transmission.enable = true;
    services.transmission.user = config.services.jellyfin.user;
    services.transmission.group = config.services.jellyfin.group;
    services.transmission.package = pkgs.transmission_4.override {
      enableGTK3 = false;
      enableQt5 = false;
      enableQt6 = false;
    };

    services.transmission.webHome = inputs.cells.common.packages.transmissionic;
    services.transmission.openRPCPort = true;
    services.transmission.openFirewall = true;
    services.transmission.settings = {
      inherit download-dir;
      message-level = 0;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "192.168.121.*,127.0.0.*";
      rpc-host-whitelist-enabled = false;
      rpc-host-whitelist = "${config.networking.hostName}";
      incomplete-dir = "${download-dir}/.incomplete";
      incomplete-dir-enabled = true;
      peer-limit-global = 500;
      peer-limit-per-torrent = 100;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 5;
    };
  }

  {
    # systemd.services.minidlna.after = [ "opt-media.mount" ];

    systemd.services.jellyfin.after = [ "opt-media.mount" ];
    systemd.services.transmission.after = [ "opt-media.mount" ];

    systemd.mounts = [{
      what = "LABEL=torrents";
      where = "/opt/media";
      type = "ext4";
      options = "defaults,noatime";
      before = [
        # "minidlna.service"
        "jellyfin.service"
        "transmission.service"
      ];
      requiredBy = [
        # "minidlna.service"
        "jellyfin.service"
        "transmission.service"
      ];
    }];
  }
]
