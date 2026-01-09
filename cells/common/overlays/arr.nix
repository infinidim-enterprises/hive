{ inputs, cell, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    # overlays = [
    #   inputs.cells.common.overlays.sources
    #   (final: prev: {
    #     navidrome = prev.navidrome.overrideAttrs (_: {
    #       inherit (final.sources.multimedia.navidrome) pname version src;
    #     });
    #   })
    # ];
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

  # jellyfin = prev.jellyfin.overrideAttrs (_: {
  #   inherit (final.sources.multimedia.jellyfin) pname version src;
  # });

  # jellyfin-web = prev.jellyfin-web.overrideAttrs (_: {
  #   inherit (final.sources.multimedia.jellyfin-web) pname version src;
  # });

  # TODO: autobrr = nixpkgs-unstable.autobrr.overrideAttrs (_: {
  #   inherit (final.sources.multimedia.autobrr) pname version src;
  #   vendorHash = "sha256-7gmF3yQFRqN7Oro/f+jhmxCUU9CltobY6EAoskCZISQ=";
  # });

  # TODO: sabnzbd = prev.sabnzbd.overrideAttrs (_: {
  #   inherit (final.sources.multimedia.sabnzbd) pname version src;
  # });

  # TODO: nzbget = prev.nzbget.overrideAttrs (_: {
  #   inherit (final.sources.multimedia.nzbget) pname version src;
  # });

  # inherit (nixpkgs-master)
  #   nzbget
  #   autobrr
  #   whisparr;

  inherit (nixpkgs-master)
    nzbget
    autobrr
    sonarr
    whisparr

    navidrome

    jellyfin
    jellyfin-ffmpeg
    jellyfin-media-player
    jellyfin-mpv-shim
    jellyfin-rpc
    jellyfin-tui
    jellyfin-web;
}
