{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    getExe
    mkForce
    mkMerge
    removePrefix
    removeSuffix
    concatStringsSep
    mapAttrsToList;

  download-dir = "/opt/media";
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
              (mapAttrsToList (k: v: "<li><a href=\"${k}\">${removePrefix "/" (removeSuffix "/" k)}</a></li>")
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

    services.nginx.enable = true;
    services.nginx.recommendedProxySettings = true;
    services.nginx.virtualHosts.${config.networking.fqdn} = {

      locations."/transmission" = {
        proxyPass = "http://localhost:9091";
        extraConfig = ''
          proxy_pass_header  X-Transmission-Session-Id;
          client_max_body_size 50000M;
        '';
      };

      locations."/transmission/rpc" = {
        proxyPass = "http://localhost:9091";
        extraConfig = ''
          proxy_pass_header  X-Transmission-Session-Id;
          client_max_body_size 50000M;
        '';
      };

    };

    services.httpd.enable = false;
    services.httpd.extraModules = [ ];

    services.httpd.virtualHosts.${config.networking.fqdn} = {
      listen = [{ ip = "*"; port = 80; }];
      documentRoot = pkgs.writeTextDir "index.html" index_html;
      extraConfig = ''
        ProxyVia On
        timeout 240
        ProxyTimeout 240
        ProxyRequests Off
        ProxyPreserveHost On
        ProxyBadHeader Ignore
        AllowEncodedSlashes NoDecode
        RequestHeader set Connection upgrade
        RequestHeader set X-Forwarded-For %{REMOTE_ADDR}s
        RequestHeader set X-Forwarded-Host %{HTTP_HOST}s
        RequestHeader set X-Original-URL %{REQUEST_URI}s
      '';

      /*

      */

      locations = {
        # "/" = {
        #   index = "index.html";
        #   alias = pkgs.writeTextDir "index.html" index_html;
        #   extraConfig = ''
        #     SetHandler None
        #   '';
        # };

        # TODO: transmission/rpc
        "/transmission" = {
          proxyPass = "http://localhost:9091/transmission/";
          extraConfig = ''
            Require all granted
            CacheDisable on
            ProxyPassReverseCookiePath /transmission/ /
            ProxyPassReverseCookieDomain localhost ${config.networking.fqdn}
            RequestHeader set X-Forwarded-Port 80
            RequestHeader set X-Real-IP %{REMOTE_ADDR}s
          '';
        };

        # "/transmission/rpc" = {
        #   proxyPass = "http://localhost:9091/transmission/rpc";
        #   extraConfig = ''
        #     Require all granted
        #     # Header always unset X-Transmission-Session-Id
        #     # Header edit Set-Cookie "(X-Transmission-Session-Id=[^;]+);" "$1"
        #     # RequestHeader set X-Transmission-Session-Id ""
        #   '';
        # };

        "/sonarr" = {
          proxyPass = "http://127.0.0.1:8989/sonarr/";
          extraConfig = ''
            ProxyPreserveHost on
          '';
        };

        "/prowlarr" = {
          proxyPass = "http://127.0.0.1:9696/prowlarr/";
          extraConfig = ''
            ProxyPreserveHost on
          '';
        };

        "/jellyfin" = {
          proxyPass = "http://127.0.0.1:8096/jellyfin";
          # extraConfig = ''
          #   Order allow,deny
          #   Allow from all
          # '';
        };

        "/jellyfin/socket" = {
          proxyPass = "ws://127.0.0.1:8096/jellyfin/socket";
          extraConfig = ''
            ProxyPreserveHost on
          '';
        };
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
      # NOTE: https://samuel.forestier.app/blog/security/how-to-secure-transmission-behind-apache-as-tls-reverse-proxy
      rpc-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-port = 9091;
      # rpc-url = "/transmission/";

      rpc-whitelist = "*";
      rpc-whitelist-enabled = false;

      rpc-host-whitelist = "*";
      rpc-host-whitelist-enabled = false;

      rpc-authentication-required = false;

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
