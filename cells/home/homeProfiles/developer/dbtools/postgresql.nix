{ pkgs, ... }:

{
  home.packages = with pkgs;[ pgcli dbeaver-bin beekeeper-studio ];
}
