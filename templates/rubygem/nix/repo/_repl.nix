{ flakePath }:
let
  lib = builtins // Flake.inputs.nixpkgs-lib.lib;
  Flake = builtins.getFlake (toString flakePath);
  Cells = Flake.${builtins.currentSystem};

  Channels =
    lib.genAttrs [
      "nixpkgs"
      "nixpkgs-unstable"
      "nixpkgs-master"
    ]
      (x: Flake.inputs.${x} // { pkgs = Flake.inputs.${x}.legacyPackages.${builtins.currentSystem}; });

  Lib = with lib; let
    inputsWithLibs = filterAttrs
      (n: v: v ? lib && !elem n (attrNames Channels))
      Flake.inputs;
    cellsWithLibs = mapAttrs
      (_: v: v.lib)
      (filterAttrs
        (n: v: v ? lib && v.lib != { })
        Flake.${builtins.currentSystem});
  in
  (mapAttrs
    (_: v: v.lib)
    (Channels // inputsWithLibs)) // { cells = cellsWithLibs; };

in
{
  inherit
    Flake
    Cells
    Channels
    Lib;
} // lib
