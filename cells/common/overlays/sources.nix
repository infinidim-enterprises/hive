{ inputs
, cell
, ...
}: final: prev:

let
  inherit (prev) callPackage;
in
{
  sources = callPackage ../sources/misc/generated.nix { };
}
