{ inputs, cell, }:
# let
#   inherit (inputs) latest nixpkgs;
#   inherit (inputs.cells) common;
# in
# common.lib.importers.importPackages {
#   nixpkgs = import latest { inherit (nixpkgs) system; };
#   sources = ./sources/generated.nix;
#   packages = ./firmwares;
# }
{ }
