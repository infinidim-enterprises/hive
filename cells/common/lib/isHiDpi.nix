{ lib, ... }:
let
  isHiDpi = {
    __functor = _self: osConfig:
      with lib;
      hasAttrByPath [ "deploy" "params" "hiDpi" ] osConfig && osConfig.deploy.params.hiDpi;

    doc = ''
      Returns true or false if the machine has hiDpi display configured
      Example:
      isHiDpi osConfig
      =>
        true
    '';
  };
in
isHiDpi
