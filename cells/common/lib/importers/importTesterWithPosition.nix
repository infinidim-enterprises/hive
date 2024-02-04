{ lib, cell, inputs, ... }:
let
  inherit (cell.lib) rakeLeaves;

  importTesterWithPosition = {
    __functor = _self:
      { src, pos ? null }:
        with (lib // builtins);
        let
          cell =
            if pos != null
            then inputs.cells."${head (match ".*-cells/([^/]+)/.*" pos)}"
            else null;
        in
        mapAttrsRecursive
          (_: v:
            let
              imported = import v;
              pred =
                cell != null
                && isFunction imported
                && (functionArgs imported) ? inputs
                && (functionArgs imported) ? cell;
            in
            if pred
            then imported { inherit inputs cell; }
            else imported)
          (rakeLeaves src);

    doc = ''
      ${builtins.trace "self" inputs.self}
    '';
  };
in
importTesterWithPosition
