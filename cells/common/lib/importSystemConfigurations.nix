{ cell, inputs, ... }:
let
  inherit (inputs) haumea;
  inherit (cell.lib) filterPath;

  # TODO: pass nixpkgs as well,  implicit bee module
  importSystemConfigurations = {
    __functor = _self:
      { src
      , skip ? [ ]
      , suites
      , profiles
      , userProfiles
      , lib
      , inputs
      , overlays ? { }
      , ...
      }:

      haumea.lib.load {
        src = filterPath { inherit skip src; };
        transformer = _: mod: mod.default or mod;
        inputs = { inherit suites profiles userProfiles lib inputs overlays; };
      };

    # TODO: doc
    doc = ''
      importSystemConfigurations
    '';
  };
in
importSystemConfigurations
