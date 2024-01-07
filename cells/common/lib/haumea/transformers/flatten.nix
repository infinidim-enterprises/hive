{ lib, ... }:
with (lib // builtins);
let
  flatten = {
    __functor = _self:
      _: v1:
        if isAttrs v1
        then
          pipe v1 [
            (mapAttrsToList
              (k2: v2:
                if isAttrs v2
                then mapAttrs' (k3: v3: nameValuePair "${k2}.${k3}" v3) v2
                else { ${k2} = v2; }
              )
            )
            (foldl' recursiveUpdate { })
          ]
        else v1;

    doc = ''
      Flatten the attribute set by concatenating the keys. Useful for
      nixosModules and homeModules.
    '';
  };
in
flatten
