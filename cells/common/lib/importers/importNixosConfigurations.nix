{ cell, inputs, lib, ... }:
let
  inherit (lib)
    mapAttrs'
    nameValuePair
    optionalAttrs;
  inherit (builtins)
    pathExists
    removeAttrs;
  inherit (inputs) haumea;
  inherit (cell.lib) filterPath;
  inherit (cell.lib.haumea.transformers) raiseDefault;

  importNixosConfigurations = {
    __functor = _self:
      { src, skip ? [ ], inputs, cell, ... }:
      let
        bootstrapPath = src + "/bootstrap";
        hasBootstrap = pathExists bootstrapPath;
        transformer = [ raiseDefault ];

        systems = haumea.lib.load
          {
            inherit transformer;
            src = filterPath { inherit skip src; };
            inputs = { inherit inputs cell; host = null; };
          };

        bootstrap = mapAttrs'
          (n: v: nameValuePair
            "${n}-bootstrap"
            (haumea.lib.load {
              inherit transformer;
              src = bootstrapPath;
              inputs = { inherit inputs cell; host = n; };
            })
          )
          (removeAttrs systems [ "bootstrap" ]);
      in
      systems // (optionalAttrs hasBootstrap bootstrap);

    doc = ''
      importNixosConfigurations { skip = [ "hostX" ]; src = ./hosts; inherit inputs cell; }
    '';
  };
in
importNixosConfigurations
