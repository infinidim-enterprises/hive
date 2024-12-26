{ inputs, cell, ... }:

final: prev:
{
  waveterm = prev.waveterm.overrideAttrs (_: {
    inherit (final.sources.waveterm) pname version;
    src = prev.fetchzip {
      inherit (final.sources.waveterm.src) url;
      hash = "sha256-UPMqrY34vRnCbzcKV5KCAl40q5QN9rpaXZSxMqxkY78=";
      stripRoot = false;
    };
  });
}
