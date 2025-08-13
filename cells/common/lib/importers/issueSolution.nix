{ inputs, lib, ... }:

let
  inherit (inputs) haumea;
  inherit (lib) isAttrs concatMapAttrs;
  flatten = attrs:
    concatMapAttrs
      (name: value:
        if isAttrs value then
        # If the directory contains a `default` attribute, we've found a package.
        # Use the directory name as the key and the default path as the value.
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
