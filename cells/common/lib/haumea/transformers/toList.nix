{ lib, ... }:
with (lib // builtins);
let
  toList = {
    __functor = _self:
      _: v: if isAttrs v then flatten (attrValues v) else [ v ];
    doc = ''
    '';
  };
in
toList
