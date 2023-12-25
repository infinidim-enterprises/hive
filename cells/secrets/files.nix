{ inputs
, cell
, ...
}:
let
  inherit (inputs) haumea nixpkgs nixpkgs-lib;
  l = nixpkgs-lib.lib // builtins;
  cells = inputs.cells;
in
{
  builder-ssh-key = builtins.readFile ./sops/ssh/root_nas.pub;
}
