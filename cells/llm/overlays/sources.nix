{ inputs, ... }:

final: prev:
let
  inherit (inputs.nixpkgs-lib.lib // builtins) hasAttr;
  sources = final.callPackage ../sources/generated.nix { };
in
if hasAttr "sources" prev
then { sources = prev.sources // { llm = sources; }; }
else { inherit sources; }
