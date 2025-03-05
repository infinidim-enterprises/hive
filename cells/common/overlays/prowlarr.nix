{ inputs, cell, ... }:
final: prev: {
  prowlarr = prev.prowlarr.overrideAttrs (_: {
    inherit (final.sources.prowlarr) pname version src;
  });
}
