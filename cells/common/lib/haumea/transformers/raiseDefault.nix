{ ... }:
# with (lib // builtins);
let
  raiseDefault = {
    __functor = _self:
      _: v: v.default or v;
    doc = ''
    '';
  };
in
raiseDefault
