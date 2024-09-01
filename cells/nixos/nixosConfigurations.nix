{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.lib.importers) importNixosConfigurations;
in
importNixosConfigurations {
  # skip = [ "damogran" ];
  skipBootstrap = [ "marauder" "damogran" ];
  src = ./hosts;
  inherit inputs cell;
}
