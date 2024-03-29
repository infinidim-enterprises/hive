{ lib, ... }:
let
  inherit (builtins)
    concatStringsSep
    attrNames
    isAttrs
    isPath
    isString
    foldl';

  flattenTree = {
    __functor = _self:

      tree:

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
          # NOTE: toPath and filterSource return a string
          if (isPath val || isString val)
          # ISSUE: https://github.com/NixOS/nix/issues/1750
          # ISSUE: https://github.com/NixOS/nix/issues/1074
          then (sum // { "${pathStr}" = val; })
          else
            if isAttrs val
            then (recurse sum path val)
            else sum;
      in
      recurse { } [ ] tree;


    doc = ''
      Synopsis: flattenTree _tree_

      Flattens a _tree_ of the shape that is produced by rakeLeaves.

      Output Format:
      An attrset with names in the spirit of the Reverse DNS Notation form
      that fully preserve information about grouping from nesting.

      Example:
        flattenTree { a = { b = { c = <path>; }; }; }
      =>
      { "a.b.c" = <path>; }
    '';
  };
in
flattenTree
