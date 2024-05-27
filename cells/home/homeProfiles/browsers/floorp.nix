{ config, lib, pkgs, ... }:

{
  # NOTE: [floorp browser] waiting on PR to be merged
  # https://github.com/nix-community/home-manager/pull/5128
  home.packages = [ pkgs.floorp ];
}
/*
  https://github.com/nix-community/home-manager/issues/5132
  { pkgs ? import <nixpkgs> {}, ... }: let
  pkg = pkgs.floorp;
  in pkg.overrideAttrs (old: {
  name = "floorp-cleaned";

  buildCommand = ''
  set -euo pipefail

  set -x
  cp -rs --no-preserve=mode "${pkg.out}" "$out"
  set +x

  rm -R $out/lib/firefox
  rm -R $out/lib/mozilla
  '';

  })
*/
