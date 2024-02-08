{ inputs, cell, ... }:
final: prev:
# FIXME: refactor sources into attrset sources.shell, sources.emacs, sources.misc etc...
{
  sources-emacs = final.callPackage ../sources/generated.nix { };
}
