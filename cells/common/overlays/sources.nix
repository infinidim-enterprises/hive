{ inputs, cell, ... }:

final: prev:
{ sources = final.callPackage ../sources/misc/generated.nix { }; }
