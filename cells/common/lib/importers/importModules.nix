{ cell, inputs, ... }:
let
  inherit (inputs) haumea;
  importModules = {
    __functor = _self:
      { src }:
      haumea.lib.load {
        inherit src;
        loader = haumea.lib.loaders.path;
      };
    doc = ''
    '';
  };
in
importModules
