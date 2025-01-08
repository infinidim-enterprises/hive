{ inputs, cell, ... }:
final: prev:
let
  nixpkgs-release = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  nixpkgs-release-24-05 = import inputs.nixos-24-05 {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

in
{
  # inherit
  #   (nixpkgs-release-24-05)
  #   atuin;

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

    gimp
    gimpPlugins
    gimp-with-plugins

    libguestfs
    jekyll

    vlc
    v4l-utils
    ffmpeg-full;
}
