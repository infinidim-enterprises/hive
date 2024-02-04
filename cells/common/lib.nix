{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib) recursiveUpdate;

  importLibs = {
    __functor = _self:
      { src ? "${inputs.self}/cells/common/lib" }:
      inputs.haumea.lib.load {
        inherit src;
        inputs = {
          inherit cell inputs;
          inherit (inputs.nixpkgs-lib) lib;

          # NOTE: why was it here? inputs = builtins.removeAttrs inputs [ "self" ];
        };
      };

    doc = ''
    '';
  };

  libs = recursiveUpdate (importLibs { }) { importers = { inherit importLibs; }; };
in
libs
