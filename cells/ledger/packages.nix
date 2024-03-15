{ inputs, cell, ... }:
cell.lib.importers.importPackagesRakeleaves {
  src = ./packages;
  overlays = with cell.overlays; [ sources python ];
  # skip = [ ];
}
