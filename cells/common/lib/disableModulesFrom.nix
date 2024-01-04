{ lib
, cell
, ...
}:
let
  disableModulesFrom = {
    __functor = _self: path:
      let
        inherit
          (lib // builtins)
          map
          removePrefix
          toPath
          attrValues
          ;
        inherit
          (cell.lib)
          flattenTree
          rakeLeaves
          ;
      in
      map
        (m: removePrefix ((toPath path) + "/") (toPath m))
        (attrValues (flattenTree (rakeLeaves path)));

    doc = ''
      Returns a list of flake modules for disabledModules
      Example:
      disableModulesFrom /path/to/modules
      =>
        [ "services/x11/window-managers/stumpwm.nix" ]
    '';
  };
in
disableModulesFrom
