{ inputs, cell, ... }:
let
  inherit (cell.lib.importers) importProfiles;
in
importProfiles {
  src = ./nixosProfiles;
  inputs = { inherit cell inputs; };
}
