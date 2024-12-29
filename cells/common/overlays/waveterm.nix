{ inputs, cell, ... }:

final: prev:
{
  waveterm = prev.waveterm.overrideAttrs (old: {
    inherit (final.sources.waveterm) pname version;
    src = prev.fetchzip {
      inherit (final.sources.waveterm.src) url;
      hash = "sha256-UPMqrY34vRnCbzcKV5KCAl40q5QN9rpaXZSxMqxkY78=";
      stripRoot = false;
    };

    preFixup = old.preFixup + ''
      cp resources/app.asar.unpacked/dist/bin/wsh-0.10.4-linux.x64 $out/bin/wsh
    '';
  });
}
