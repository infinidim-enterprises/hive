{ pkgs, ... }:

{
  home.packages = with pkgs;[ mycli ];
}
