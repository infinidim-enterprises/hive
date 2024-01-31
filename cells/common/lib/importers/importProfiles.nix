{ cell, inputs, ... }:
let
  inherit (inputs) haumea;
  importProfiles = {
    __functor = _self:
      { inputs ? { }, src, ... }:
      haumea.lib.load {
        inherit src inputs;
        # transformer = haumea.lib.transformers.liftDefault;
        transformer = cell.lib.haumea.transformers.raiseDefault;
      };
    doc = ''
    '';
  };
in
importProfiles
