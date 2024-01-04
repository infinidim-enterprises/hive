{ lib, cell, inputs, ... }:
let
  inherit (lib // builtins) recursiveUpdate fromJSON readFile;
  inherit (inputs) std nixpkgs;

  callFlake = {
    __functor = _self:
      src: overrides:
        let
          # lockFile = recursiveUpdate (fromJSON (readFile (src + "/flake.lock"))) { nodes = overrides; };
          compatFlake = import "${inputs.flake-compat}" { inherit src; };
        in
        inputs.std.inputs.paisano.inputs.nosys.lib.deSys nixpkgs.system compatFlake.defaultNix.inputs;
    # if nosys
    # then inputs.std.inputs.paisano.inputs.nosys.lib.deSys nixpkgs.system compatFlake.defaultNix.inputs
    # else compatFlake.defaultNix.inputs;

    doc = ''
      callFlake
    '';
  };
in
callFlake
