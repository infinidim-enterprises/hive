{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
# TODO: zrepl backups of /home
{
  services.zrepl.enable = true;
  services.zrepl.settings = {
    global.logging = [{
      type = "syslog";
      level = "info";
      format = "human";
    }];

    jobs = [
      {
        name = "home";
        type = "sink";
        root_fs = "rpool/home";
        serve = {
          type = "tls";
          listen = ":8888";
          ca = config.age.secrets.scadrial-crt.path;
          cert = config.age.secrets.cultivation-crt.path;
          key = config.age.secrets.cultivation-key.path;
          client_cns = [ "scadrial" ];
        };
      }
    ];

  };
}
