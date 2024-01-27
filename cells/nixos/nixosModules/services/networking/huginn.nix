{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.huginn;

  image = "huginn/huginn-single-process";
  imageFile = pkgs.dockerTools.pullImage {
    imageName = "huginn/huginn-single-process";
    imageDigest = "sha256:0a4f88049ebe7b429ea6cc4615e425c75d39db59af6bd6ec48a2371d462e83c3";
    sha256 = "0d42gav0pmnl87xjw7q9x2pgz9s6fx5n7yy8pff9hbcdwaw4dx24";
    finalImageName = "huginn/huginn-single-process";
    finalImageTag = "latest";
  };

  environment = {
    MYSQL_PORT_3306_TCP_ADDR = "mysql";
    MYSQL_ROOT_PASSWORD = "myrootpassword";
    HUGINN_DATABASE_HOST = "huginn-mysql";
    HUGINN_DATABASE_PASSWORD = "myrootpassword";
    HUGINN_DATABASE_USERNAME = "root";
    HUGINN_DATABASE_NAME = "huginn";
    APP_SECRET_TOKEN = "3bd139f9186b31a85336bb89cd1a1337078921134b2f48e022fd09c234d764d3e19b018b2ab789c6e0e04a1ac9e3365116368049660234c2038dc9990513d49c";
  };

  extraOptions = [ "--link" "huginn-mysql" ];
in
{
  options.services.huginn = with types; {
    enable = mkEnableOption "Huginn in container";
    log-driver = mkOption { type = str; default = "journald"; };
    environment = mapAttrs'
      (k: default:
        nameValuePair k (mkOption { type = str; inherit default; }))
      environment;
    agents = mkOption {
      type = int;
      default = 1;
      apply = workers: listToAttrs (imap1
        (_: i: nameValuePair "huginn-agent-${toString i}-of-${toString workers}" {
          inherit image imageFile extraOptions;
          inherit (cfg) environment log-driver;
          dependsOn = [ "huginn-web" "huginn-mysql" ];
          cmd = [ "/scripts/init" "bin/threaded.rb" ];
        })
        (range 1 workers));
      description = "Amount of workers to run";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.services.docker-huginn-web.serviceConfig.StandardOutput = "null";

      virtualisation.oci-containers.containers = {

        huginn-mysql = {
          inherit (cfg) environment log-driver;
          volumes = [ "/persist/huginn-mysql:/var/lib/mysql" ];
          image = "mysql";
          imageFile = pkgs.dockerTools.pullImage {
            imageName = "mysql";
            imageDigest = "sha256:b3a86578a582617214477d91e47e850f9e18df0b5d1644fb2d96d91a340b8972";
            sha256 = "1giwd1qlmk08ysxw5wlg1hg8zknkkgdd38gf8niiz6lcbjq3kman";
            finalImageName = "mysql";
            finalImageTag = "5.7";
          };
        };

        huginn-web = {
          inherit image imageFile extraOptions;
          inherit (cfg) environment log-driver;
          dependsOn = [ "huginn-mysql" ];
        };

      } // cfg.agents;
    })
  ];
}
