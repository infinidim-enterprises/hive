{ inputs, cell, ... }:

final: prev:
{
  sources = prev.sources // {
    llm = final.callPackage ../sources/generated.nix { };
  };
}
