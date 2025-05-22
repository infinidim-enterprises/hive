{ inputs, cell, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in

final: prev: {
  radarr = prev.radarr.overrideAttrs (_: {
    inherit (final.sources.multimedia.radarr) pname version src;
  });

  prowlarr = prev.prowlarr.overrideAttrs (_: {
    inherit (final.sources.multimedia.prowlarr) pname version src;
  });

  lidarr = prev.lidarr.overrideAttrs (_: {
    inherit (final.sources.multimedia.lidarr) pname version src;
  });

  readarr = prev.readarr.overrideAttrs (_: {
    inherit (final.sources.multimedia.readarr) pname version src;
  });

  inherit (nixpkgs-unstable)
    whisparr;
}
