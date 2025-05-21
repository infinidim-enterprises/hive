{ lib, cell, inputs, ... }:
let
  inherit (lib // builtins)
    isDerivation
    toString
    path;
  inherit (inputs) call-flake;

  callFlake = {
    __functor = _self:
      path_or_drv:
      call-flake (toString (path {
        path =
          if isDerivation path_or_drv
          then path_or_drv.outPath
          else (toString path_or_drv);
      }));

    doc = ''
      callFlake from a store path, making sure it is realized
    '';
  };
in
callFlake
