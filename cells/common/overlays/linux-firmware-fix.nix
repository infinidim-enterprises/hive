{ inputs, cell, ... }:
final: prev:
let
  working_iwlwifi = import inputs.nixpkgs-linux-firmware {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

in
{ inherit (working_iwlwifi) linux-firmware; }
