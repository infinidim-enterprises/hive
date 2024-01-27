{ inputs, cell, ... }:
final: prev:
{
  sources = final.callPackage ../sources/generated.nix { };
}
