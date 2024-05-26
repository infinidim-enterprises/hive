{ pkgs, lib, config, ... }:
with lib;
let
  zshEnable = config.programs.zsh.enable;
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
    }
  ];
}
