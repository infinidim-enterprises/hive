{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.lib.importers) importNixosConfigurations;
in
importNixosConfigurations {
  # skip = [  ];
  src = ./hosts;
  inherit inputs cell;
}
