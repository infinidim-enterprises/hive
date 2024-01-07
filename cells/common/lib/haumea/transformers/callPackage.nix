{ lib, ... }:
with (lib // builtins);
let
  callPackage = {
    __functor = _self:
      { pkgs, extraArguments }:
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
            (mapAttrs' (k: v:
              let
                ka = splitString "." k;
                name = toLower (elemAt ka ((length ka) - 1));
              in
              nameValuePair name v))
          ]
        #else pkgs.callPackage (dirOf v1) ({ } // extraArguments);
        else pkgs.callPackage (dirOf v1);
    # TODO: doc
    doc = ''
      callPackage { pkgs }
    '';
  };
in
callPackage
