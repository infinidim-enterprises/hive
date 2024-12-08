{ pkgs, ... }:
{
  home.packages = with pkgs; [
    masterpdfeditor
    poppler_utils
    # conflicts with texlive tetex
  ];
}
