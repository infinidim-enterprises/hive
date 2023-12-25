{ lib, ... }:
let
  importCredentials = {
    __functor = _self: { pkgs
                       , location ? ../../secrets/credentials.nix
                       ,
                       }: sym: default:
      let
        inherit location;
        inherit (builtins) pathExists isString;
        inherit (pkgs) runCommandNoCCLocal file;
        inherit (lib) concatStringsSep singleton attrByPath hasInfix fileContents;
        isNotEncrypted = src:
          hasInfix "text"
            (fileContents (runCommandNoCCLocal "chk-encryption"
              {
                buildInputs = [ file ];
                inherit src;
              }
              "file $src > $out"));
        hasCredentials =
          if pathExists location && isNotEncrypted location
          then true
          else false;
        path =
          if isString sym
          then singleton sym
          else sym;
        pathStr = concatStringsSep "." path;
        suicide = throw "Can't find attribute path `${pathStr}' in credentials.";
        creds = import location { inherit lib; };
      in
      if hasCredentials
      then attrByPath path suicide creds
      else default;
    doc = ''
      { pkgs, location ? ../../secrets/credentials.nix }:
    '';
  };
in
importCredentials
