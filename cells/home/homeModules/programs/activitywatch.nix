{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.activitywatch;
  zshEnable = config.programs.zsh.enable;
in
{
  options.programs.activitywatch = with types; {
    enable = mkEnableOption "Enable activitywatch";
    settings = {
      aw-server = {
        port = mkOption { type = int; default = 5600; apply = toString; };
        host = mkOption { type = str; default = "127.0.0.1"; };
      };
    };
    package = mkOption { type = package; default = pkgs.activitywatch; };
  };

  config = mkMerge [
    (mkIf (cfg.enable && zshEnable) {
      programs.zsh.plugins = [
        {
          name = "aw-watcher-shell";
          file = "aw-watcher-shell";
          src = pkgs.sources.zsh-plugin_aw-watcher-shell.src;
        }
      ];
    })

    (mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.activitywatch-server = {
        Unit.Description = "activitywatch server";
        Unit.Before = [ "graphical-session.target" ];
        Service.ExecStart = (pkgs.writeShellScript "activitywatch-server" ''
          export PATH=$PATH:${makeBinPath [cfg.package]}
          aw-server --host ${cfg.settings.aw-server.host} --port ${cfg.settings.aw-server.port}
        '').outPath;
        Service.TimeoutStartSec = 5;
        Service.Restart = "on-failure";
        Install.WantedBy = [ "default.target" ];
      };

    })
  ];
}
