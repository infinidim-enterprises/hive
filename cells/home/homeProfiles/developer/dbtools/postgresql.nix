{ pkgs, osConfig, localLib, lib, ... }:
let
  inherit (lib // builtins) mkMerge mkIf;
in
mkMerge [
  { home.packages = with pkgs;[ pgcli ]; }

  (mkIf (localLib.isGui osConfig) {
    home.packages = with pkgs;[ dbeaver-bin beekeeper-studio ];
  })
]
