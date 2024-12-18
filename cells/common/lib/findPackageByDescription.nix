{ lib, ... }:
let
  inherit (lib // builtins)
    filterSource
    filterAttrs
    isDerivation
    hasAttrByPath
    concatStringsSep
    match
    elem
    toString;

  findPackageByDescription = {
    __functor = _self:
      { patterns, pkgs, platform ? "x86_64-linux" }:

      filterAttrs
        (k: v:
          isDerivation (builtins.tryEval v).value &&
          hasAttrByPath [ "meta" "description" ] v &&
          hasAttrByPath [ "meta" "platforms" ] v &&
          elem platform v.meta.platforms &&
          # TODO: (?i) - match ignore case
          (match ".*(${concatStringsSep "|" patterns})" v.meta.description) != null)
        pkgs;

    doc = ''
      Filters packages, that have matched regex on their meta.description attribute

      Example:
        findPackageByDescription { patterns = [ "" "value2" ]; inherit (Flake.nixosConfigurations.nixos-oglaroon) pkgs; }
      =>
        { pkg = drv; }
    '';
  };
in
findPackageByDescription
