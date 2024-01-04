{ lib
, cell
, ...
}:
let
  inherit (cell.lib) rakeLeaves;
  importFolder = {
    __functor = _self: path:
      with lib;
      attrValues (filterAttrs (k: v: k != "default" && !(isAttrs v)) (rakeLeaves path));

    doc = ''
      Creates a list of .nix files, suitable for imports statement
      Example:
      importFolder ./.
      =>
        ["/path/to/module.nix"]
    '';
  };
in
importFolder
