{ pkgs, ... }:
{
  home.packages = with pkgs; [
    evince # GNOME's document viewer
    font-manager # Simple font management for GTK desktop environments
    foliate # A simple and modern GTK eBook reader

    # REVIEW: okular # KDE thing, maybe? pdf reader
  ];
}
