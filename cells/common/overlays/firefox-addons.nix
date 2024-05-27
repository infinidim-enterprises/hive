{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib) mapAttrs;
in
final: prev:
let
  inherit ((prev.appendOverlays [ inputs.nur.overlay ]).nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
in
{
  firefox-addons = mapAttrs
    (_: v: buildFirefoxXpiAddon v)
    (final.callPackage ../sources/firefox/generated.nix { });

}
