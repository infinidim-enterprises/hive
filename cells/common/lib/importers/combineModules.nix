{ cell, lib, ... }:
let
  inherit (cell.lib.importers) importModules;
  inherit (builtins) attrValues;

  combineModules = {
    __functor = _self:
      { src }: _:
        { imports = attrValues (importModules { inherit src; }); };
    doc = ''
    '';
  };
in
combineModules
