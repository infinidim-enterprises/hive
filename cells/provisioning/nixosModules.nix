{ inputs
, cell
,
}:
let
  inherit (inputs.cells) common;
in
{
  provision = common.lib.importers.combineModules {
    src = ./nixosModules;
  };
}
