{lib, ...}: let
  flattenAttrs = {
    __functor = _self: attrs:
      with lib;
        concatLists (collect isList attrs);

    doc = ''
      Concatenates all lists in a nested attrs, ignoring the names and
      all non-list values.
      Example:
        flattenAttrs { a = [ 1 2 3 ]; b = { c = [ 4 5 6 ]; d = "hello"; }; }
      =>
        [ 1 2 3 4 5 6 ]
    '';
  };
in
  flattenAttrs
