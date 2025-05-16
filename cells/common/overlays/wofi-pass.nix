{ inputs, cell, ... }:

final: prev:

{
  wofi-pass = (prev.wofi-pass.overrideAttrs (_: {
    inherit (final.sources.wofi-pass) pname version src;
  })).override { extensions = (e: [ e.pass-otp ]); };
}
