{ inputs, cell, ... }:

inputs.cells.common.lib.importers.importPackagesRakeleaves {
  src = ./packages;
  overlays = [ cell.overlays.sources ];
}
