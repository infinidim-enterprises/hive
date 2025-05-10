{ inputs, cell, ... }:
final: prev:
# TODO: refactor sources into attrset sources.shell, sources.emacs, sources.misc etc...
{
  sources-emacs = final.callPackage ../sources/generated.nix { };
  sources = prev.sources // { emacs = final.callPackage ../sources/generated.nix { }; };
}
