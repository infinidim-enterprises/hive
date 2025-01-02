{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.lib.importers) importNixosConfigurations;
in
importNixosConfigurations {
  skip = [ "kate" ];
  skipBootstrap = [ "kate" "marauder" "damogran" ];
  src = ./hosts;
  inherit inputs cell;
}
