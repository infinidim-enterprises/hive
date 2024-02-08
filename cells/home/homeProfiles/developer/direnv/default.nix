{ config, lib, pkgs, ... }:
lib.mkMerge [

  (lib.mkIf config.programs.vscode.enable {
    programs.vscode.extensions = [ pkgs.vscode-extensions.vscode-direnv ];
  })

  (lib.mkIf config.programs.zsh.enable {
    programs.direnv.enableZshIntegration = true;
  })

  (lib.mkIf config.programs.bash.enable {
    programs.direnv.enableBashIntegration = true;
  })

  {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.direnv.config = {
      global.warn_timeout = "2m";
    };

    # xdg.configFile."direnv/direnv.toml".text = ''
    #   [global]
    #   warn_timeout = "2m"
    # '';
  }
]
