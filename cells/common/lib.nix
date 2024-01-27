{ inputs, cell, ... }:
let
  inherit (inputs) haumea;
  inherit (inputs.nixpkgs-lib) lib;
  inherit (builtins) removeAttrs;

  importLibs = { src ? ./lib }:
    haumea.lib.load {
      inherit src;
      inputs = {
        inputs = removeAttrs inputs [ "self" ];
        inherit lib cell;
      };
    };
in
{ inherit importLibs; } // (importLibs { })
