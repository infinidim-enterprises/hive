{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) latest nixpkgs;
in {
  misc = cell.lib.importPackages {
    nixpkgs = import latest {inherit (nixpkgs) system;};
    sources = ./sources/misc/generated.nix;
    packages = ./packages;
  };
}
