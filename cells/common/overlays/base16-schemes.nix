{ inputs, cell, ... }:

final: prev: {
  base16-schemes = prev.base16-schemes.overrideAttrs (_: {
    inherit (final.sources.base16-schemes) pname version src;
  });
}
