{ inputs, cell, ... }:
final: prev:
let
  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
{
  inherit
    (nixpkgs-master)
    gimp-with-plugins
    activitywatch;
}
