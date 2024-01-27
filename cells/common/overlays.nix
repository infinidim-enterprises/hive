{ inputs, cell, ... }:
let
  inherit (inputs) haumea;
in
(haumea.lib.load {
  src = ./overlays;
  inputs = { inherit inputs cell; };
  transformer = haumea.lib.transformers.liftDefault;
})
  //
  # cell.lib.importRakeLeaves ./overlays { inherit inputs cell; }
{
  common-packages = _: _: cell.packages.misc;
  # latest-overrides = _: _: cell.overrides;
  # sources.zsh
}
