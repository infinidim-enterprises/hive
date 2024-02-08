{ cell, inputs, ... }:
let
  inherit (inputs) haumea;
  inherit (cell.lib) filterPath;
  inherit (cell.lib.haumea.transformers) raiseDefault;

  importNixosConfigurations = {
    __functor = _self:
      { src, skip ? [ ], inputs, cell, ... }:

      haumea.lib.load {
        src = filterPath { inherit skip src; };
        transformer = [ raiseDefault ];
        inputs = { inherit inputs cell; };
      };

    doc = ''
      importNixosConfigurations { skip = [ "hostX" ]; src = ./hosts; inherit inputs cell; }
    '';
  };
in
importNixosConfigurations
