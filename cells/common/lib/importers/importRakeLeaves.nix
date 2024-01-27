{ lib
, cell
, ...
}:
with lib; let
  inherit (cell.lib) rakeLeaves;
  importRakeLeaves = {
    __functor = _self:
      path: args:
        mapAttrsRecursive
          (_: v:
            if (isFunction (import v))
            then import v args
            else import v)
          (rakeLeaves path);

    doc = ''
      importRakeLeaves { inherit inputs, cell, ... }
    '';
  };
in
importRakeLeaves
