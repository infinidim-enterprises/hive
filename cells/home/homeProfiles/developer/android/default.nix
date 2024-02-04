{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # heimdall
    heimdall-gui
  ];
}
