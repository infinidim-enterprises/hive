{ pkgs, ... }:

{
  home.packages = with pkgs;[ pgcli dbeaver beekeeper-studio ];
}
