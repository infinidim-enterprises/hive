{ inputs, cell, ... }:
inputs.cells.common.lib.importers.importPackagesRakeleaves {
  nixpkgs = inputs.nixpkgs-master;
  src = ./packages;
  overlays = [
    cell.overlays.sources
    inputs.gomod2nix.overlays.default
  ];
}
