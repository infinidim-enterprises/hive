{ pkgs, ... }:

{
  home.packages = with pkgs; [ yarn2nix ];
}
