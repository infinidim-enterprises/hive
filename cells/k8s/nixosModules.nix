{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.lib.importers) combineModules;
in
{ k8s = combineModules { src = ./modules; }; }
