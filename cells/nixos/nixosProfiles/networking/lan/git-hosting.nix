{ inputs, cell, ... }:

{ self, config, lib, pkgs, containers, ... }:
with lib;
let
  lan = config.deploy.params.lan.server;
  cfg = lan.git-hosting;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  namespace = "lan-" + lan.domain;
  gitea-pkg = pkgs.gitea;
in

mkMerge [
  {
    age.secrets."gitea-admin" = {
      file = "${self}/secrets/shared/gitea-admin.age";
      mode = "0750";
      owner = "10000";
      group = "100";
      path = "/run/secrets/gitea-admin";
    };
  }

  {
    containers."${namespace}-git-hosting" = {
      additionalCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      inherit (lan) macvlans;

      timeoutStartSec = "120s";
      autoStart = true;
      ephemeral = true;

      bindMounts.gitea-admin.hostPath = "/run/secrets/gitea-admin";
      bindMounts.gitea-admin.mountPoint = "/run/secrets/gitea-admin";
      bindMounts.gitea-admin.isReadOnly = true;

      bindMounts.git-path.hostPath = "/persist/git";
      bindMounts.git-path.mountPoint = "/git";
      bindMounts.git-path.isReadOnly = false;

      config = { config, pkgs, lib, ... }: {
        imports = containers.systemd;

        networking.hostName = "git";
        networking.domain = lan.domain;
        networking.firewall.allowedTCPPorts = [ 80 22 ];

        deploy.params.lan.dhcpClient = false;
        systemd.network.networks.lan = { inherit (cfg) addresses; inherit (lan) networkConfig; };

        services.httpd.enable = true;
        services.httpd.virtualHosts.git-hosting = {
          hostName = "git.${lan.domain}";
          adminAddr = "git-httpd@${lan.domain}";
          listen = [{ ip = localAddress; port = 80; }];
          extraConfig = ''
            ProxyPreserveHost On
            ProxyRequests off
            AllowEncodedSlashes NoDecode
            ProxyPass / http://localhost:3000/ nocanon
            ProxyPassReverse / http://localhost:3000/
          '';
        };

        users.users.gitea = {
          uid = 10000;
          shell = pkgs.bashInteractive;
          packages = [
            (pkgs.writeShellScriptBin "gitea" ''
              GITEA_WORK_DIR=${config.services.gitea.stateDir} ${config.services.gitea.package}/bin/gitea "$@"
            '')
          ];
        };

        systemd.services.gitea.path = [ config.services.gitea.package ];

        systemd.services.gitea.postStart = ''
          . /run/secrets/gitea-admin
          gitea admin user create --admin \
            --username "''${USERNAME_ADMIN}" \
            --password "''${PASSWORD_ADMIN}" \
            --email "''${EMAIL_ADMIN}" &> /dev/null || true
        '';

        services.memcached.enable = true;
        services.memcached.maxMemory = 64;

        services.openssh.enable = lib.mkForce true;

        # TODO: ensure host permissions!
        # config.ids.uids.postgres
        services.postgresql.dataDir = "/git/postgresql";

        services.gitea = {
          enable = true;
          package = gitea-pkg;
          # TODO: git backups!
          # dump.enable = true;
          # dump.backupDir = "";
          # dump.interval = "03:30";

          log.level = "Error"; # Trace, Debug
          repositoryRoot = "/git/repos";
          stateDir = "/git/gitea";
          rootUrl = "http://git.${lan.domain}";
          useWizard = false;
          httpAddress = "127.0.0.1";
          httpPort = 3000;

          user = "gitea";
          disableRegistration = true;
          appName = "git.${lan.domain}";
          cookieSecure = false;
          database.createDatabase = true;
          database.type = "postgres"; #  "sqlite3"

          lfs.enable = true;
          lfs.contentDir = "/git/lfs";

          settings = {
            security.DISABLE_GIT_HOOKS = false;

            ui.DEFAULT_THEME = "arc-green";

            server.DISABLE_ROUTER_LOG = true;

            service.DEFAULT_ORG_VISIBILITY = "private";

            repository.DEFAULT_PRIVATE = true;
            repository.ENABLE_PUSH_CREATE_ORG = true;
            repository.ENABLE_PUSH_CREATE_USER = true;

            cache.ENABLED = true;
            cache.ADAPTER = "memcache";
            cache.HOST = "localhost:11211";

            session.PROVIDER = "memcache";
            session.PROVIDER_CONFIG = "localhost:11211";

            time.FORMAT = "RFC1123Z";
            time.DEFAULT_UI_LOCATION = "Europe/Berlin";
          };
        };

      };
    };
  }
]
