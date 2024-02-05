{ inputs
, cell
,
}:
let
  inherit (inputs.cells) common nixos;
in
common.lib.importers.importProfiles {
  src = ./profiles;

  inputs = {
    common = common.commonProfiles;
    nixos = nixos.nixosProfiles;
    inherit cell inputs;
  };
}
