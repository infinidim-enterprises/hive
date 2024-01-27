{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.lib.importers) importProfiles;
in
importProfiles {
  src = ./nixosProfiles;
  inputs = { inherit cell inputs; };
}
