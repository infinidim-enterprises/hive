{ pkgs, lib, config, ... }:
with lib;

let
  zshEnable = config.programs.zsh.enable;
  isX11 = pkgs.writeShellApplication {
    name = "isX11";
    runtimeInputs = with pkgs; [ systemd gnugrep ];
    text = ''
      if [ -z "$1" ]; then
          echo "Usage: $0 <username>"
          exit 1
      fi

      username="$1"

      while true; do
          session_ids=$(loginctl show-user "$username" --property=Sessions --value)
          for session_id in $session_ids; do
              session_type=$(loginctl show-session "$session_id" --property=Type --value)
              if [ "$session_type" == "x11" ]; then
                  systemctl --user import-environment DISPLAY
                  exit 0
              fi
          done
          sleep 3
      done
    '';
  };
  ExecStartPre = "${isX11}/bin/isX11 %u";
  BindsTo = [ "graphical-session.target" ];

in
{
  config = mkMerge [
    (mkIf zshEnable {
      programs.zsh.plugins = [
        {
          name = "aw-watcher-shell";
          file = "aw-watcher-shell";
          src = pkgs.sources.zsh-plugin_aw-watcher-shell.src;
        }
      ];
    })

    {
      services.activitywatch.enable = true;
      services.activitywatch.watchers = {
        aw-watcher-afk = {
          package = pkgs.activitywatch;
          settings = {
            timeout = 300;
            poll_time = 3;
          };
        };

        aw-watcher-window = {
          package = pkgs.activitywatch;
          settings = {
            poll_time = 3;
            # exclude_title = true;
          };
        };

        # my-custom-watcher = {
        #   package = pkgs.my-custom-watcher;
        #   executable = "mcw";
        #   settings = {
        #     hello = "there";
        #     enable_greetings = true;
        #     poll_time = 5;
        #   };
        #   settingsFilename = "config.toml";
        # };

      };

      systemd.user.services.activitywatch-watcher-aw-watcher-window = {
        Service = { inherit ExecStartPre; };
        Unit = { inherit BindsTo; };
      };
      systemd.user.services.activitywatch-watcher-aw-watcher-afk = {
        Service = { inherit ExecStartPre; };
        Unit = { inherit BindsTo; };
      };

    }
  ];
}
