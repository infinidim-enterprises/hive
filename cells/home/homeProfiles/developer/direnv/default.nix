{ config, lib, pkgs, ... }:
lib.mkMerge [
  (lib.mkIf config.programs.vscode.enable {
    programs.vscode.extensions = [ pkgs.vscode-extensions.vscode-direnv ];
  })

  {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    # programs.direnv.nix-direnv.enableFlakes = true;
  }
]
