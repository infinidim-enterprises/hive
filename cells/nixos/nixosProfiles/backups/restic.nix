{ inputs, cell, ... }:

{ user, extraDirs ? [ ], ... }:

{ config, lib, pkgs, ... }:

let
  baseDir = config.users.users.${user}.home + "/";
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

  sops.secrets.restic_passwd = {
    key = "restic_passwd";
    sopsFile = ../../../secrets/sops/online-storage-systems.yaml;
  };

  services.restic.backups."home-${user}" = {
    inherit paths;
    initialize = true;
    timerConfig.OnCalendar = "hourly";
    timerConfig.Persistent = true;
    extraBackupArgs = [ "--compression max" "--no-cache" "--with-atime" ];
    passwordFile = config.sops.secrets.restic_passwd.path;
    rcloneConfigFile = config.sops.secrets.rclone_conf.path;
    repository = "rclone:backups:/backups/${user}";
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 50"
    ];
  };
}
