{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib) mapAttrs;
in
final: prev:
let
  nixpkgs = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    overlays = [ cell.overlays.sources ];
    config.allowUnfree = true;
  };

  flake = cell.lib.callFlake nixpkgs.sources.misc.nur.src;

  inherit ((nixpkgs.appendOverlays [ flake.overlays.default ]).nur.repos) rycee;
  inherit (rycee.firefox-addons) buildFirefoxXpiAddon;
  inherit (rycee) mozilla-addons-to-nix;
in
{
  inherit mozilla-addons-to-nix;
  firefox-addons = mapAttrs
    (_: v: buildFirefoxXpiAddon v)
    (final.callPackage ../sources/firefox/generated.nix { });

  # firefox_decrypt = prev.firefox_decrypt.overrideAttrs (_: {
  #   inherit (final.sources.firefox_decrypt) pname version src;
  # });
}
