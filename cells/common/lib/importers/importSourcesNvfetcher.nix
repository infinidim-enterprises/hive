{ cell, lib, ... }:
let
  inherit (builtins) mapAttrs removeAttrs;
  inherit (cell.lib.importers) rakeLeaves;

  importSourcesNvfetcher = {
    __functor = _self:
      { dir, callPackage }:

      mapAttrs
        (_: v: removeAttrs
          (callPackage v.generated { })
          [ "override" "overrideDerivation" ])
        (rakeLeaves dir);

    doc = ''
    '';
  };
in
importSourcesNvfetcher
