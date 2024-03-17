{ inputs, cell, ... }:
let
  crystal_fresh = import inputs.crystal-1_11_2_pr {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
final: prev:
{
  inherit (crystal_fresh) crystal shards;
  crystalline = crystal_fresh.crystalline.overrideAttrs (_: {
    inherit (final.sources.crystalline) pname version src;
  });

}
