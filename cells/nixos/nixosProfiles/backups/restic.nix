{ inputs, cell, ... }:

{ user, extraDirs ? [ ], OnCalendar ? "*-*-* 0/8:00:00", ... }:

{ config, lib, ... }:

let
  inherit (lib)
    getExe
    findFirst
    hasInfix;

  baseDir = config.users.users.${user}.home + "/";
  defaultDirs = [
    # "Desktop"
    "Documents"
    # "Downloads"
    "Logs"
    # "Music"
    "Pictures"
    # "Public"
    "Templates"
    # "Videos"
    # "Projects"
  ];

  paths = map (p: baseDir + p) (defaultDirs ++ extraDirs);
  name = "home-${user}-${config.networking.hostName}";
  cmd = getExe
    (findFirst
      (e: hasInfix "restic-${name}" e)
      null
      config.environment.systemPackages);
in

{
  services.restic.backups.${name} = {
    inherit paths;
    initialize = true;
    inhibitsSleep = true;
    timerConfig = {
      # NOTE: defaults to every 8 hours, otherwise bandwidth limit exceeds on some rclone remotes
      inherit OnCalendar;
      Persistent = true;
    };
    extraBackupArgs = [
      "--compression max"
      "--no-cache"
      "--with-atime"
      "--exclude-caches"
    ];
    passwordFile = config.sops.secrets.restic_passwd.path;
    rcloneConfigFile = config.sops.secrets.rclone_conf.path;
    repository = "rclone:backups:/backups/${user}/${config.networking.hostName}";
    backupPrepareCommand = "${cmd} unlock";
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 50"
    ];
  };
}
