{ ... }:

let
  inherit (builtins)
    removeAttrs
    isAttrs;
in
{
  __functor = _: _: mod:
    if mod ? default then
      if isAttrs mod.default
      then (removeAttrs mod [ "default" ]) // mod.default
      else mod.default
    else mod;

  doc = "";
}
