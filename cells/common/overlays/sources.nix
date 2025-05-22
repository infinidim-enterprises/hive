{ inputs, cell, ... }:
# TODO: refactor sources into attrset sources.shell, sources.emacs, sources.misc etc...
final: prev:
{
  sources = (prev.sources or { }) // (
    inputs.cells.common.lib.importers.importSourcesNvfetcher {
      inherit (final) callPackage;
      dir = ../sources;
    }
  ) //
    (final.callPackage ../sources/misc/generated.nix { });
}
