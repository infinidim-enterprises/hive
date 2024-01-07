{ inputs
, cell
, ...
}:
let
  inherit (inputs) latest nixpkgs;
in
{
  misc = cell.lib.importers.packages {
    # nixpkgs = import latest { inherit (nixpkgs) system; };
    src = ./packages;
    overlays = [ cell.overlays.sources ];
    skip = [
      "TakeTheTime"
      "age-plugin-yubikey"
      "activitywatch"
      "promnesia"
      "HPI"
      "aw-client"
      "aw-core"

    ];
  };
}
