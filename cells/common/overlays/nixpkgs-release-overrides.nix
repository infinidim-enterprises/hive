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
    atuin

    nyxt

    # chromium
    # libreoffice-bin
    # libreoffice-still
    # onlyoffice-bin
    # onlyoffice-bin_latest

    gimp
    gimpPlugins
    gimp-with-plugins;
}
