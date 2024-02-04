{ pkgs, ... }:
{
  home.packages = with pkgs; [
    masterpdfeditor
    poppler_utils
    # conflicts with texlive tetex
  ];

  # [General]
  # app_style=Default
}
