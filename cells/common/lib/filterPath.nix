{ lib, ... }:
let
  inherit (builtins)
    filterSource
    concatStringsSep
    match
    toString;

  filterPath = {
    __functor = _self:
      { skip ? [ ], src }:
      if skip != [ ]
      then filterSource (path: _: (match ".*(${concatStringsSep "|" skip})" (toString path)) == null) src
      else src;
    doc = ''
      Filters a path, produces a path without matched regex

      Example:
        filterPath { skip = [ "value1" "value2" ]; src = /some/path; }
      =>
        /some/path
    '';
  };
in
filterPath
