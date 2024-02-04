{ pkgs, ... }:
{
  home.packages = with pkgs; [ evince font-manager ];
}
