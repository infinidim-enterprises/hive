{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib) mapAttrs nameValuePair;
in
final: prev:
{
  firefox-addons =
    (mapAttrs
      (_: v:
        nameValuePair _ (final.fetchFirefoxAddon { inherit (v) url sha256; name = v.pname; }))
      (final.callPackage ../sources/firefox/generated.nix { }));
}
