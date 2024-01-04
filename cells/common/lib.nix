{ inputs
, cell
, ...
}:
let
  inherit (inputs) haumea;
  inherit (inputs.nixpkgs-lib) lib;
  inherit (builtins) attrValues removeAttrs;

  importLibs = { src ? ./lib }:
    haumea.lib.load {
      inherit src;
      inputs = {
        inputs = removeAttrs inputs [ "self" ];
        inherit lib cell;
      };
    };
in
rec
{
  inherit importLibs;

  importProfiles =
    { inputs ? { }
    , src
    , ...
    }:
    haumea.lib.load {
      inherit src inputs;
      transformer = haumea.lib.transformers.liftDefault;
    };

  importModules = { src }:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
    };

  combineModules = { src }: _: {
    imports = attrValues (importModules { inherit src; });
  };
}
  // (importLibs { })
