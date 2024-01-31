{ config, lib, pkgs, self, name, ... }:
with lib;
let
  cfg = config.programs.promnesia;
  cfgXdg = config.xdg.mimeApps.enable;
in
{
  options.programs.promnesia = with types; {
    enable = mkEnableOption "Enable promnesia backend";
    configFile = mkOption {
      type = oneOf [ path package string ];
      default = "${self}/users/${name}/dotfiles/promnesia/config.py";
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfgXdg) {

      xdg.mimeApps.defaultApplications."x-scheme-handler/editor" = "editor-protocol.desktop";

      xdg.desktopEntries.editor-protocol = {
        icon = "emacs";
        name = "editor-protocol";
        exec = with pkgs; (writeShellScript "editor-protocol" ''
          ${python3}/bin/python ${sources.open-in-editor.src}/open_in_editor.py --editor emacs $@
        '').outPath + " %u";
        terminal = false;
        type = "Application";
        comment = "promnesia editor:// support";
        categories = [ "Utility" "System" ];
        mimeType = [ "x-scheme-handler/editor" ];
      };
    })

    (mkIf cfg.enable {
      systemd.user.services.promnesia = {
        Unit.Description = "promnesia Daemon";
        Service.ExecStartPre = (pkgs.writeShellScript "promnesia-reindex" ''
          ${pkgs.promnesia}/bin/promnesia index --config ${cfg.configFile} || true
        '').outPath;
        Service.ExecStart = "${pkgs.promnesia}/bin/promnesia serve";
        Service.TimeoutStartSec = 120;
        Service.Restart = "on-failure";
        Service.StandardOutput = "null";
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.promnesia-restarter = {
        Service.Type = "oneshot";
        Service.ExecStart = ''
          ${pkgs.systemd}/bin/systemctl --user restart promnesia.service
        '';

        Install.WantedBy = [ "promnesia.service" ];
      };

      systemd.user.paths.promnesia-watcher = {
        Path.PathModified = "%h/Documents/org";
        Path.Unit = "promnesia-restarter.service";
        Install.WantedBy = [ "promnesia.service" ];
      };

      home.packages = with pkgs; [ promnesia ];
      xdg.configFile."promnesia/config.py".source = cfg.configFile;
    })
  ];
}
