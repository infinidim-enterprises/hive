{ inputs, lib, ... }:

let
  inherit (inputs) haumea;
  inherit (lib) isAttrs concatMapAttrs;
  flatten = attrs:
    concatMapAttrs
      (name: value:
        if isAttrs value then
          if value ? default
          then { ${name} = value.default; }
          else flatten value
        else { ${name} = value; })
      attrs;
in

src:

haumea.lib.load {
  inherit src;
  loader = haumea.lib.loaders.path;
  transformer = [ (_: attrs: flatten attrs) ];
}
