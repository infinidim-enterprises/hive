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

  firefox_decrypt = prev.firefox_decrypt.overrideAttrs (_: {
    inherit (final.sources.firefox_decrypt) pname version src;
  });
}
