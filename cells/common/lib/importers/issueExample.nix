{ inputs, ... }:

let
  inherit (inputs) haumea;
  inherit (inputs.nixpkgs-lib.lib)
    foldl'
    attrNames
    concatStringsSep
    isPath
    isString
    isAttrs
    mapAttrs'
    nameValuePair
    last
    splitString;

  flattenTree = tree:
    let
      recurse = sum: path: val:
        foldl'
          (sum: key: op sum (path ++ [ key ]) val.${key})
          sum
          (attrNames val);

      op = sum: path: val:
        let
          pathStr = concatStringsSep "." path;
        in
        if (isPath val || isString val)
        then (sum // { "${pathStr}" = val; })
        else
          if isAttrs val
          then (recurse sum path val)
          else sum;
    in
    recurse { } [ ] tree;

  importPackages = src:
    let
      attrTree = haumea.lib.load {
        inherit src;
        loader = haumea.lib.loaders.path;
        transformer = [ (_: v: v.default or v) ];
      };

    in
    mapAttrs'
      (k: v: nameValuePair (last (splitString "." k)) v)
      (flattenTree attrTree);
in
importPackages
