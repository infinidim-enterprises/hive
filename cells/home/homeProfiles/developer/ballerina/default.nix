{ lib, pkgs, config, ... }:
with lib;
mkMerge [
  {
    home.packages = with pkgs; [
      maven
      openjdk11
    ];
  }

  (mkIf config.programs.vscode.enable {
    # ISSUE: programs.vscode.extensions = with pkgs.vscode-extensions; [ ballerina ];
  })
]
