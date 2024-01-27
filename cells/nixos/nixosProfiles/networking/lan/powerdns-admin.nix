{ inputs, cell, ... }:

{ config, self, lib, pkgs, containers, ... }:
with lib;
let
  cfg = config.deploy.params.lan.server.powerdns-admin;
  lan = config.deploy.params.lan.server;
  localAddress = head (splitString "/" (head (cfg.addresses)).addressConfig.Address);
  sqlHostAddress = head (splitString "/" (head (lan.postgresql.addresses)).addressConfig.Address);
  sameHost = hasAttrByPath [ "containers" "powerdns" ] config;
  namespace = "lan-" + lan.domain;
in

mkMerge [
  (mkIf sameHost {
    systemd.services."container@${namespace}-powerdns-admin".partOf = [ "container@${namespace}-powerdns-native.service" ];
    systemd.services."container@${namespace}-powerdns-admin".after = [
      "container@${namespace}-postgresql-dns-dhcp.service"
      "container@${namespace}-powerdns-native.service"
    ];
  })

  {
    age.secrets."powerdns-admin" = {
      file = "${self}/secrets/shared/powerdns-admin-secret-key.age";
      mode = "0600";
      owner = "999";
      group = "998";
      path = "/run/secrets/powerdns-admin.secret";
    };

    age.secrets."powerdns-admin-salt" = {
      file = "${self}/secrets/shared/powerdns-admin-secret-salt.age";
      mode = "0600";
      owner = "999";
      group = "998";
      path = "/run/secrets/powerdns-admin-salt.secret";
    };
    #   bindMounts.powerdns-admin-secret.hostPath = "/run/secrets/powerdns-admin.secret";
    #   bindMounts.powerdns-admin-secret.mountPoint = "/run/secrets/powerdns-admin.secret";
    #   bindMounts.powerdns-admin-secret.isReadOnly = false;

    #   bindMounts.powerdns-admin-secret-salt.hostPath = "/run/secrets/powerdns-admin-salt.secret";
    #   bindMounts.powerdns-admin-secret-salt.mountPoint = "/run/secrets/powerdns-admin-salt.secret";
    #   bindMounts.powerdns-admin-secret-salt.isReadOnly = false;

    systemd.services."${namespace}-powerdns-admin-netSetup" = {
      path = with pkgs; [ jq docker ];
      before = [ "docker-${namespace}-powerdns-admin.service" ];
      wantedBy = [ "docker-${namespace}-powerdns-admin.service" ];
      script = ''
        _create_docker_network() {
          docker network create -d macvlan \
            -o parent=${head lan.macvlans} \
            --subnet=${lan.network} \
            --gateway=${lan.networkConfig.Gateway} \
            pdns-admin
        }
        ! docker network ls --format '{{json .}}' | jq -e --arg admin_net pdns-admin 'select(.Name == $admin_net and .Driver =="macvlan") | any' | grep -q true && _create_docker_network || true
      '';
    };

    virtualisation.oci-containers.containers."${namespace}-powerdns-admin" = {
      autoStart = true;
      image = "ngoduykhanh/powerdns-admin";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "ngoduykhanh/powerdns-admin";
        imageDigest = "sha256:733a48988fe853cdd0be1a74901b4aff6f30ba33d5270a62bcd595f95f6245c0";
        sha256 = "1h24zjzhakdbin4246nhhi9d21aqdszifx57splbpsfkjzjnrlm4";
      };

      environment = {
        SQLALCHEMY_DATABASE_URI = "postgresql://powerdnsadmin:powerdnsadmin@/powerdnsadmin?host=${sqlHostAddress}";
        GUNICORN_TIMEOUT = "60";
        GUNICORN_WORKERS = "2";
        GUNICORN_LOGLEVEL = "INFO";
        OFFLINE_MODE = "False";
      };

      extraOptions = [
        "--ip=${localAddress}"
        "--network=pdns-admin"
      ];

      # volumes = [
      #   "/sys/fs/cgroup:/sys/fs/cgroup"
      # ];

      # ports = [ "9191:80/tcp" ];
    };
    networking.firewall.allowedTCPPorts = [ 9191 ];

  }
]
