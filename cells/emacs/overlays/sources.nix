{ inputs, cell, ... }:
final: prev:

{
  sources = (prev.sources or { }) // (
    inputs.cells.common.lib.importers.importSourcesNvfetcher {
      inherit (final) callPackage;
      dir = ../sources;
    }
  );
}
