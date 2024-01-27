{ inputs
, cell
, ...
}:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.common.lib.importers) importNixosConfigurations;
  lib = nixpkgs.lib // builtins;
  cells = inputs.cells;
in
importNixosConfigurations {
  skip = [
    # "oglaroon" # FIXME: remove when oglaroon works!

    "depsos"
    "hyperos"
    "nas"
    "octoprint"
    "oracle"
    "rockiosk"
    "voron"
  ];
  src = ./hosts;

  inherit inputs cell lib;
  suites = cell.nixosSuites;
  profiles =
    cell.nixosProfiles
    // {
      common = cells.common.commonProfiles;
      secrets = cells.secrets.nixosProfiles.secrets;
      users = cells.home.users.nixos;
    };
  userProfiles = cells.home.userProfiles;
}
