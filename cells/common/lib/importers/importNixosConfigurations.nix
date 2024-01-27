{ cell, inputs, ... }:
let
  inherit (inputs) haumea;
  inherit (cell.lib) filterPath;
  inherit (cell.lib.haumea.transformers) raiseDefault;

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
      , cell
      , overlays ? { }
      , ...
      }:

      haumea.lib.load {
        src = filterPath { inherit skip src; };
        transformer = [ raiseDefault ];
        inputs = {
          inherit
            suites
            profiles
            userProfiles
            lib
            inputs
            cell
            overlays;
        };
      };

    # TODO: doc
    doc = ''
      importSystemConfigurations
    '';
  };
in
importSystemConfigurations
