# FIXME: / NOTE: this is because of the overlay named 'sources'
# the dart package doesn't load its own sources, since an attribute is already found
{ inputs, cell, ... }:
final: prev: {
  dart = prev.dart.override {
    sources = import
      "${inputs.nixpkgs-unstable}/pkgs/development/compilers/dart/sources.nix"
      { inherit (prev) fetchurl; };
  };
}
