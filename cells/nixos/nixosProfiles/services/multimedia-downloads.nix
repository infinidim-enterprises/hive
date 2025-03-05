{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    getExe
    mkForce
    mkMerge
    removePrefix
    concatStringsSep
    mapAttrsToList;

  download-dir = "/opt/media";
  # media_dirs =
  #   with config.systemd.services.jellyfin.serviceConfig;
  #   map
  #     (e: "chown --recursive ${User}:${Group} "
  #       + (last (splitString "," e)))
  #     config.services.minidlna.settings.media_dir;

  index_html = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Service Links</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            ul { list-style-type: none; padding: 0; }
            li { margin: 10px 0; }
            a { text-decoration: none; color: #0073e6; font-size: 18px; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <h1>Available Services</h1>
        <ul>
            ${concatStringsSep "\n"
              (mapAttrsToList (k: v: "<li><a href=\"${k}\">${removePrefix "/" k}</a></li>")
                config.services.httpd.virtualHosts.${config.networking.fqdn}.locations)}
        </ul>
    </body>
    </html>
  '';
in
mkMerge [
  { boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288; }

  {
    networking.firewall.allowedTCPPorts = [ 80 ];
    services.httpd.enable = true;
    services.httpd.virtualHosts.${config.networking.fqdn} = {
      listen = [{ ip = "*"; port = 80; }];
      documentRoot = pkgs.writeTextDir "index.html" index_html;
      locations = {
        "/torrent" = { proxyPass = "http://localhost:9091"; };
        "/sonarr" = { proxyPass = "http://localhost:8989"; };
        "/prowlarr" = { proxyPass = "http://localhost:9696"; };
        "/jellyfin" = { proxyPass = "http://localhost:8096"; };
      };
    };
  }

  {
    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = false;

    networking.firewall.allowedUDPPorts = [
      1900 # DLNA
      7359 # jellyfin native clients
    ];

    systemd.services.jellyfin-fix-perms.wantedBy = [ "jellyfin.service" ];
    systemd.services.jellyfin-fix-perms.script =
      with config.services.jellyfin;
      ''
        chown --recursive ${user}:${group} ${download-dir}
      '';

    systemd.services.jellyfin.after = [ "jellyfin-fix-perms.service" ];
  }

  {
    services.sonarr.enable = true;
    services.sonarr.user = config.services.jellyfin.user;
    services.sonarr.group = config.services.jellyfin.group;
    services.sonarr.openFirewall = false;
    services.sonarr.dataDir = download-dir + "/sonarr";
    systemd.services.sonarr.after = [ "jellyfin.service" ];
  }

  {
    services.prowlarr.enable = true;
    services.prowlarr.openFirewall = false;

    systemd.services.prowlarr.serviceConfig.DynamicUser = mkForce false;
    systemd.services.prowlarr.serviceConfig.User = config.services.jellyfin.user;
    systemd.services.prowlarr.serviceConfig.Group = config.services.jellyfin.group;
    systemd.services.prowlarr.serviceConfig.ExecStart = mkForce "${getExe config.services.prowlarr.package} -nobrowser -data=${download-dir + "/prowlarr"}";
    systemd.services.prowlarr.after = [ "jellyfin.service" ];

    systemd.tmpfiles.rules = [
      "d '${download-dir + "/prowlarr"}' 0700 ${config.services.jellyfin.user} ${config.services.jellyfin.group} - -"
    ];
  }

  {
    services.transmission.enable = true;
    services.transmission.user = config.services.jellyfin.user;
    services.transmission.group = config.services.jellyfin.group;
    services.transmission.performanceNetParameters = true;
    services.transmission.package = pkgs.transmission_4.override {
      enableGTK3 = false;
      enableQt5 = false;
      enableQt6 = false;
    };

    services.transmission.webHome = inputs.cells.common.packages.transmissionic;
    services.transmission.openRPCPort = false;
    services.transmission.openFirewall = false;
    services.transmission.settings = {
      inherit download-dir;
      message-level = 0;
      rpc-port = 9091;
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist = "127.0.0.*";
      rpc-host-whitelist-enabled = false;
      rpc-host-whitelist = "localhost,127.0.0.*,${config.networking.hostName}";
      incomplete-dir = "${download-dir}/.incomplete";
      incomplete-dir-enabled = true;
      peer-limit-global = 500;
      peer-limit-per-torrent = 100;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 5;
    };
  }

  {
    systemd.services.jellyfin.after = [ "opt-media.mount" "httpd.service" ];
    systemd.services.transmission.after = [ "opt-media.mount" "httpd.service" ];

    systemd.mounts = [{
      what = "LABEL=torrents";
      where = "/opt/media";
      type = "ext4";
      options = "defaults,noatime";
      before = [
        "jellyfin.service"
        "transmission.service"
      ];
      requiredBy = [
        "jellyfin.service"
        "transmission.service"
      ];
    }];
  }
]
