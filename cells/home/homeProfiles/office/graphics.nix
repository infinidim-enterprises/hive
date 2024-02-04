{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nomacs
    inkscape
    gimp-with-plugins
    imagemagick
  ];
}
