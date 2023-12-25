{ lib, ... }:
let
  hostConfig = {
    __functor = _self: hostName:
      with lib;
      with builtins; let
        cfg = (getFlake (toPath (getEnv "PRJ_ROOT"))).nixosConfigurations.${hostName};
        fileSystems = filterAttrs (n: v: v.fsType != "auto") cfg.fileSystems;
      in
      { inherit cfg; };

    doc = ''
      Config extractor for scripts
    '';
  };
in
hostConfig
