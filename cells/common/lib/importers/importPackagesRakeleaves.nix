{ lib, cell, inputs, ... }:
let
  inherit (cell.lib)
    flattenTree
    filterPath;
  inherit (cell.lib.importers) rakeLeaves;

  packages = {
    __functor = _self:
      { src
      , skip ? [ ]
      , nixpkgs ? inputs.latest
      , system ? inputs.nixpkgs.system
      , overlays ? [ ]
      , extraArguments ? { }
      , ...
      }:

        with (lib // builtins);
        let
          pkgs = import nixpkgs {
            inherit overlays system;
            allowUnfree = true;
          };
        in
        mapAttrs'
          (k: v: nameValuePair
            (last (splitString "." k))
            (pkgs.callPackage v ({ } // extraArguments)))

          (flattenTree (rakeLeaves (filterPath { inherit skip src; })));

    doc = ''
      packages
    '';
  };
in
packages
