{ inputs, cell, ... }:

final: prev:
let
  inherit (inputs.nixpkgs) system;
  inherit (inputs.nixpkgs-lib) lib;
  # with-namespace
  inherit (inputs.devos-ext-lib.${system}.vscode-extensions.builders) no-namespace;
  srcs = builtins.removeAttrs
    (final.callPackage ../sources/vscode/generated.nix { })
    [ "override" "overrideDerivation" ];
in
{
  vscode-extensions = lib.recursiveUpdate
    prev.vscode-extensions
    (no-namespace { inherit srcs; });
}
