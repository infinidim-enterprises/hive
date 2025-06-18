{ lib, ... }:
let
  inherit (lib // builtins)
    toLower
    filterAttrs
    isDerivation
    hasAttrByPath
    concatStringsSep
    match
    elem;

  findPackageByDescription = {
    __functor = _self:
      { patterns, pkgs, platform ? "x86_64-linux" }:

      filterAttrs
        (k: v:
          isDerivation (builtins.tryEval v).value &&
          hasAttrByPath [ "meta" "description" ] v &&
          hasAttrByPath [ "meta" "platforms" ] v &&
          elem platform v.meta.platforms &&
          (match ".*(${concatStringsSep "|" patterns})" (toLower v.meta.description)) != null)
        pkgs;

    doc = ''
      Filters packages, that have matched regex on their meta.description attribute, ignore case sensitivity

      Example:
        findPackageByDescription { patterns = [ "" "value2" ]; inherit (host) pkgs; }
      =>
        { pkg = drv; }
    '';
  };
in
findPackageByDescription
