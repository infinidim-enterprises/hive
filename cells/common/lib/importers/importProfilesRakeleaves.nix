{ lib, cell, inputs, ... }:
let
  inherit (cell.lib.importers) rakeLeaves;

  importProfilesRakeleaves = {
    __functor = _self:
      { src, inputs ? { } }:
        with (lib // builtins);
        mapAttrsRecursive
          (_: v:
            let
              imported = import v;
              pred =
                (functionArgs imported) ? inputs ||
                (functionArgs imported) ? cell;
            in
            if (isFunction imported) && pred
            then imported inputs
            else imported)
          (rakeLeaves src);

    doc = ''
    '';
  };
in
importProfilesRakeleaves
