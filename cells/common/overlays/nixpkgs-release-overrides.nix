{ inputs, cell, ... }:
final: prev:
let
  nixpkgs-release = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
{
  inherit
    (nixpkgs-release)

    firefox
    chromium

    sambaFull
    borgbackup

    libreoffice
    libreoffice-bin
    libreoffice-still

    onlyoffice-bin
    onlyoffice-bin_latest

    # gimp
    # gimpPlugins
    # gimp-with-plugins

    zenity

    libguestfs
    jekyll

    vlc
    v4l-utils
    ffmpeg-full;
}
