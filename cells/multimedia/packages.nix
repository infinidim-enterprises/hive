{ cell, inputs, ... }:
inputs.flakelib.lib.import.packages {
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) system;
  src = ./packages;
  overlays = builtins.attrValues cell.overlays;
}
