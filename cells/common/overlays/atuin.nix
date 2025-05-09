{ inputs, cell, ... }:

final: prev:

{
  atuin = prev.atuin.overrideAttrs (_: {
    inherit (final.sources.atuin) pname version src;
    cargoLock = {
      lockFileContents = final.sources.atuin."Cargo.lock";
    };

  });
}
