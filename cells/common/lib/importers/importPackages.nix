{ lib, cell, inputs, ... }:
let
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
          inherit (inputs) haumea;
          inherit (cell.lib) filterPath;

          pkgs = import nixpkgs {
            inherit overlays system;
            allowUnfree = true;
          };
        in

        haumea.lib.load {
          src = filterPath { inherit skip src; };
          loader = haumea.lib.loaders.path;
          transformer = with cell.lib.haumea.transformers;
            [
              raiseDefault
              (callPackage { inherit pkgs extraArguments; })
            ];
        };

    # TODO: doc
    doc = ''
      packages
    '';
  };
in
packages
