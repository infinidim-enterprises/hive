{ inputs, cell, ... }:

{ lib, pkgs, config, ... }:
let
  inherit (lib // builtins)
    head
    match
    imap0
    getExe
    mkForce
    mkMerge
    removeAttrs
    concatStringsSep
    mapAttrsToList;

  download-dir = "/opt/media";
  regex = "^[^/]*/([^(]*)\\(.*";

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
              (imap0 (i: e: if i > 0 then "        " + e else e) (mapAttrsToList (k: v:
                let
                  link_name = head (match regex k);
                in
                  "<li><a href=\"/${link_name}\">${link_name}</a></li>")
                (removeAttrs config.services.nginx.virtualHosts.${config.networking.fqdn}.locations ["/"])))}
        </ul>
    </body>
    </html>
  '';

  process_audio_download = with pkgs; writeShellApplication {
    name = "process_audio_download";
    # excludeShellChecks = [ "SC2153" "SC2317" "SC2046" ];
    runtimeInputs = [
      jq
      sox
      flac
      id3v2
      mp3splt
      shntool
      cuetools
      vorbis-tools
      ffmpeg-headless

      gnugrep
      findutils
      util-linux
      coreutils-full
    ];
    text = lib.fileContents ./process_audio_download.sh;
  };

in
{
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/servarr/whisparr.nix" ];
  config = mkMerge [
    { boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288; }

    {
      networking.firewall.allowedTCPPorts = [ 80 ];

      services.nginx.enable = true;
      # NOTE: https://github.com/NixOS/nixpkgs/issues/156956#issuecomment-2282360607
      services.nginx.recommendedProxySettings = true;
      services.nginx.virtualHosts.${config.networking.fqdn} = {
        locations."/".root = pkgs.writeTextDir "index.html" index_html;

        locations."~* ^/transmission(/rpc|/web)?(/.*)?$" = {
          proxyPass = "http://localhost:9091";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_pass_header  X-Transmission-Session-Id;
            client_max_body_size 50000M;
          '';
        };

        locations."~* ^/jellyfin(/.*)?$" = {
          proxyPass = "http://localhost:8096";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # proxy_set_header Host $host;

            proxy_set_header Range $http_range;
            proxy_set_header If-Range $http_if_range;

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;

            proxy_buffering off;
            client_max_body_size 20M;
          '';
        };

        locations."~* ^/radarr(/.*)?$" = {
          proxyPass = "http://localhost:7878";
          proxyWebsockets = true;
        };

        locations."~* ^/sonarr(/.*)?$" = {
          proxyPass = "http://localhost:8989";
          proxyWebsockets = true;
        };

        locations."~* ^/lidarr(/.*)?$" = {
          proxyPass = "http://localhost:8686";
          proxyWebsockets = true;
        };

        locations."~* ^/readarr(/.*)?$" = {
          proxyPass = "http://localhost:8787";
          proxyWebsockets = true;
        };

        locations."~* ^/whisparr(/.*)?$" = {
          proxyPass = "http://localhost:6969";
          proxyWebsockets = true;
        };

        locations."~* ^/prowlarr(/.*)?$" = {
          proxyPass = "http://localhost:9696";
          proxyWebsockets = true;
        };

      };
    }

    {
      services.jellyfin.enable = true;
      services.jellyfin.openFirewall = false;

      # NOTE: zt-central hosted
      services.zerotierone.joinNetworks = [{ "272f5eae16028184" = "jellyfin"; }];

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
      systemd.services.jellyfin.serviceConfig.Restart = mkForce "always";
      systemd.services.jellyfin.after = [ "jellyfin-fix-perms.service" ];
    }

    {
      services.radarr.enable = true;
      services.radarr.user = config.services.jellyfin.user;
      services.radarr.group = config.services.jellyfin.group;
      services.radarr.openFirewall = false;
      services.radarr.dataDir = download-dir + "/radarr";
      systemd.services.radarr.after = [ "prowlarr.service" ];
    }

    {
      services.sonarr.enable = true;
      services.sonarr.user = config.services.jellyfin.user;
      services.sonarr.group = config.services.jellyfin.group;
      services.sonarr.openFirewall = false;
      services.sonarr.dataDir = download-dir + "/sonarr";
      systemd.services.sonarr.after = [ "prowlarr.service" ];
    }

    {
      # TODO: beets with_plugins [ Chroma fetchart lyrics lastgenre mbsync scrub embedart badfiles thumbnails convert duplicates export fuzzy info ]
      services.lidarr.enable = true;
      services.lidarr.user = config.services.jellyfin.user;
      services.lidarr.group = config.services.jellyfin.group;
      services.lidarr.openFirewall = false;
      services.lidarr.dataDir = download-dir + "/lidarr";
      systemd.services.lidarr.after = [ "prowlarr.service" ];
    }

    {
      services.readarr.enable = true;
      services.readarr.user = config.services.jellyfin.user;
      services.readarr.group = config.services.jellyfin.group;
      services.readarr.openFirewall = false;
      services.readarr.dataDir = download-dir + "/readarr";
      systemd.services.readarr.after = [ "prowlarr.service" ];
    }

    {
      services.whisparr.enable = true;
      services.whisparr.user = config.services.jellyfin.user;
      services.whisparr.group = config.services.jellyfin.group;
      services.whisparr.openFirewall = false;
      services.whisparr.dataDir = download-dir + "/whisparr";
      systemd.services.whisparr.after = [ "prowlarr.service" ];
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
      environment.systemPackages = with pkgs; [
        process_audio_download

        jq
        sox
        flac
        mp3splt
        id3v2
        shntool
        cuetools
        vorbis-tools
        ffmpeg-headless

        tvnamer
      ];

      # NOTE: timer_create required to use flock
      systemd.services.transmission.serviceConfig.SystemCallFilter = [ "@timer" ];

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
        download-dir = download-dir + "/downloads";
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

        script-torrent-done-enabled = true;
        script-torrent-done-filename = "${process_audio_download}/bin/process_audio_download";
      };
    }

    {
      services.samba.enable = true;
      services.samba.nmbd.enable = false;
      services.samba.package = pkgs.sambaFull;
      services.samba.openFirewall = true;
      services.samba.settings = {
        global = {
          "usershare path" = "/var/lib/samba/usershares";
          "usershare max shares" = "100";
          "usershare allow guests" = "yes";
          "usershare owner only" = "yes";
          "disable netbios" = "yes";
          "smb ports" = "445";
          "guest account" = "nobody";
          "map to guest" = "Bad User";
        };

        media = {
          "path" = "/opt/media";
          "read only" = false;
          "browseable" = "yes";
          "guest ok" = "yes";
          "valid users" = "admin";
          "force user" = "jellyfin";
        };
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
  ];
}
