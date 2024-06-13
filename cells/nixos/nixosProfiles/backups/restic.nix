{ inputs, cell, ... }:

{ user, extraDirs ? [ ], ... }:

{ config, lib, pkgs, ... }:

let
  baseDir = config.users.users.${uname}.home + "/";
  defaultDirs = [
    "Desktop"
    "Documents"
    "Downloads"
    "Logs"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
    "Projects"
  ];

  paths = map (p: baseDir + p) (defaultDirs ++ extraDirs);
in

{
  sops.secrets.rclone_conf = {
    sopsFile = ../../../secrets/sops/rclone.conf;
    format = "binary";
  };

  services.restic.backups."home-${user}" = {
    inherit paths;
    initialize = true;
    timerConfig.OnCalendar = "hourly";
    timerConfig.Persistent = true;
    # environmentFile = config.sops.secrets.rclone_conf;
    rcloneConfigFile = config.sops.secrets.rclone_conf.path;
    repository = "rclone:mega_50GB:/backups/${user}";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
