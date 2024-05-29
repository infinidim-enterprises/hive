{ inputs, cell, ... }:
final: prev:
{
  linux-firmare = prev.linux-firmare.overrideAttrs (_: {
    inherit (final.sources.linux-firmare) version src;
  });
}
