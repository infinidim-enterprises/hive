{ inputs, cell, ... }:

inputs.cells.common.lib.importers.importProfiles {
  src = ./homeProfiles;
  inputs = { inherit inputs cell; };
}
