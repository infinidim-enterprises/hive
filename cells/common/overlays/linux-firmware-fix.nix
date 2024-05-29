{ inputs, cell, ... }:
final: prev:
{
  linux-firmware = prev.linux-firmware.overrideAttrs (_: {
    inherit (final.sources.linux-firmware) version src;
  });
}
