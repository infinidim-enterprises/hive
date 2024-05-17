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
      { src, skip ? [ ], inputs, cell, bootstrapSystem ? "bootstrap", ... }:
      let
        bootstrapPath = src + "/${bootstrapSystem}";
        hasBootstrap = pathExists bootstrapPath;
        transformer = [ raiseDefault ];

        systems = haumea.lib.load
          {
            inherit transformer;
            src = filterPath { inherit skip src; };
            inputs = { inherit inputs cell; host = null; };
          };

        # NOTE: secrets management - install a bootstrap->get the public ssh key->install the target system
        bootstrap = mapAttrs'
          (n: v: nameValuePair
            "${n}-bootstrap"
            (haumea.lib.load {
              inherit transformer;
              src = bootstrapPath;
              inputs = { inherit inputs cell; host = n; };
            })
          )
          (removeAttrs systems [ bootstrapSystem ]);
      in
      systems // (optionalAttrs hasBootstrap bootstrap);

    doc = ''
      importNixosConfigurations { skip = [ "hostX" ]; src = ./hosts; bootstrapSystem = "path/to/bootstrap/system/inside/''${src}"; inherit inputs cell; }
    '';
  };
in
importNixosConfigurations
