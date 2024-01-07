{ lib, cell, inputs, ... }:
let
  inherit (inputs) haumea;
  inherit (cell.lib) filterPath;

  importTester = {
    __functor = _self:
      { src
      , skip ? [ ]
      , nixpkgs ? inputs.latest
      , system ? inputs.nixpkgs.system
      , overlays ? [ ]
      , ...
      }:

        with (lib // builtins);

        let
          pkgs = import nixpkgs {
            inherit overlays system;
            allowUnfree = true;
          };
        in

        haumea.lib.load {
          src = filterPath { inherit skip src; };
          loader = haumea.lib.loaders.path;
          transformer = with cell.lib.haumea.transformers; [
            raiseDefault
            (callPackage { inherit pkgs; })
          ];
        };

    # TODO: doc
    doc = ''
      importTester
    '';
  };
in
importTester
