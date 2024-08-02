{ inputs, ... }:

let
  inherit (inputs) haumea;
  inherit (inputs.nixpkgs-lib.lib)
    mapAttrs'
    nameValuePair
    last
    splitString;

  transformer = {
    __transform__ = {
      from = "path";
      to = "attr";
      transform = v: {
        ${last (splitString "." v)} = v;
      };
    };
  };

  importPackages = src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = [ transformer ];
    };

in
importPackages
