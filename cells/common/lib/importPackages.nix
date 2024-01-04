{ lib, cell, inputs, ... }:
let
  inherit (cell.lib)
    flattenTree
    rakeLeaves
    filterPath;
  inherit (lib)
    mapAttrs'
    nameValuePair
    last
    splitString
    filterAttrs;
  inherit (builtins)
    isPath;

  importPackages = {
    __functor = _self:
      { nixpkgs ? (import inputs.nixpkgs { inherit (inputs.nixpkgs) system; })
      , sources ? null
      , extraArguments ? { }
      , packages
      , skip ? [ ]
      , ...
      }:
      let
        sources' =
          if isPath sources
          then (nixpkgs.callPackage sources { })
          else sources;
        pkgs =
          mapAttrs'
            (k: v: nameValuePair
              (last (splitString "." k))
              (nixpkgs.callPackage v (extraArguments // { sources = sources'; })))

            (flattenTree (rakeLeaves (filterPath { inherit skip; src = packages; })));
      in
      pkgs // { sources = sources'; };

    # TODO: doc
    doc = ''
      importPackages
    '';
  };
in
importPackages
