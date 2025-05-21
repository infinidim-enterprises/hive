{ lib, cell, inputs, ... }:
let
  inherit (lib // builtins)
    isDerivation
    mapAttrs
    readFile
    toString
    path;
  call-flake = import "${inputs.call-flake}/call-flake.nix";
  callFlakeWithOverrides = {
    __functor = _self:
      { src, overrides ? { } }:
      let
        outPath = toString (path {
          path =
            if isDerivation src
            then src.outPath
            else (toString src);
        });

        lockstr = readFile "${outPath}/flake.lock";
        flakeref = {
          root = { sourceInfo = { inherit outPath; }; subdir = ""; };
        } // (mapAttrs (_: v: cell.lib.callFlake v) overrides);
      in
      call-flake lockstr flakeref;

    doc = ''
      callFlakeWithOverrides from a store path with input overrides

      callFlakeWithOverrides { src = "store path or drv"; overrides = { input_name = "store path or drv"; }; }
    '';
  };
in
callFlakeWithOverrides
